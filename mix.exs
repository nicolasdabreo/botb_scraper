defmodule BotbScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :botb_scraper,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:crawly, "~> 0.15"},
      {:floki, "~> 0.34"},
      {:briefly, "~> 0.3"},
      {:finch, "~> 0.15"},
      {:multipart, "~> 0.3"}
    ]
  end
end
