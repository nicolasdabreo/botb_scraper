defmodule ExtractDataset do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.botb.com"

  @impl Crawly.Spider
  def init() do
    [start_urls: ["https://www.botb.com/winners/sc375"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    id = System.unique_integer([:positive])
    winner_name = Floki.find(document, "span.winner-name") |> Floki.text()
    [game_image_src] = Floki.find(document, "img.game_image") |> Floki.attribute("src")
    image_path = save_image_to_file_system!(game_image_src, id)
    object_name = upload_file_to_s3(image_path, winner_name)
    [image_height, image_width] = extract_image_dimensions_from_file!(image_path) |> IO.inspect()
    [judged_coordinates_string] = Floki.find(document, "#judged_checkbox") |> Floki.attribute("data-label") |> IO.inspect(label: "coordinates")
    [judged_x, judged_y] = extract_coordinates_from_label_string(judged_coordinates_string)

    item =
      %{
        id: id,
        title: winner_name,
        url: response.request_url,
        object_name: object_name,
        image_height: image_height,
        image_width: image_width,
        judged_x: judged_x,
        judged_y: judged_y
      }
      |> IO.inspect()

    %{items: [item], requests: []}
  end

  defp save_image_to_file_system!(src, image_title) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(src, [timeout: 60_000, recv_timeout: 30_000]) |> IO.inspect()
    {:ok, path} = Briefly.create()
    File.write!(path, body)
    path
  end

  defp upload_file_to_s3(image_path, image_title) do
    image_title = "#{image_title}.jpeg"
    local_file = File.read!(image_path)
    ExAws.S3.put_object(bucket(), image_title, local_file) |> ExAws.request!()
    image_title
  end

  defp bucket do
    Application.fetch_env!(:botb_scraper, :image_bucket)
  end

  defp extract_image_dimensions_from_file!(image_path) do
    image = Image.open!(image_path)
    width = Image.width(image)
    height = Image.height(image)
    [height, width]
  end

  defp extract_coordinates_from_label_string(input_string) do
    x =
      case Regex.run(~r/X (\d+)/, input_string) do
        [_, match] -> match |> String.to_integer()
        _ -> nil
      end

    y =
      case Regex.run(~r/Y (\d+)/, input_string) do
        [_, match] -> match |> String.to_integer()
        _ -> nil
      end

    [x, y]
  end
end
