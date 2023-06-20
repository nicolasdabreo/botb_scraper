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
      {:image, "~> 0.33"},
      {:ex_aws, "~> 2.4"},
      {:ex_aws_s3, "~> 2.4"},
      {:hackney, "~> 1.18"},
      {:sweet_xml, "~> 0.7"},
      {:jason, "~> 1.5-alpha.1"},
      {:briefly, "~> 0.4"}
    ]
  end
end
