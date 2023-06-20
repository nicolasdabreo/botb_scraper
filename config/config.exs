import Config

item_fields = [:id, :url, :title, :image_name, :image_height, :image_width, :judged_x, :judged_y]

config :crawly,
  closespider_timeout: 10,
  # Only issue one request at a time (self-preservation)
  concurrent_requests_per_domain: 1,
  #
  follow_redirects: true,
  # Set to `:disabled` to crawl ALL records
  closespider_itemcount: 1,
  log_dir: "/tmp/spider_logs",
  log_to_file: true,

  # Use CSV output
  output_format: "csv",
  item: item_fields,

  middlewares: [
    # Dont schedule the same request multiple times
    Crawly.Middlewares.UniqueRequest,
    # Set our UserAgent header to something informative to be nice to their Sys-admins
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]},
    # We're downloading large images so give some breathing room
    {Crawly.Middlewares.RequestOptions, [timeout: 60_000, recv_timeout: 30_000]}
  ],
  pipelines: [
    Crawly.Pipelines.DuplicatesFilter,
    {Crawly.Pipelines.CSVEncoder, fields: item_fields},
    {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "csv", include_timestamp: true}
  ]

config :ex_aws,
  json_codec: Jason,
  region: "eu-west-2",
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

config :botb_scraper,
  image_bucket: "imagestoredabreoai"
