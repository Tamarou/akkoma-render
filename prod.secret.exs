import Mix.Config

config :pleroma, Pleroma.Web.Endpoint,
  url: [host: "akkoma.example.com"]

config :pleroma, Pleroma.Web.WebFinger, domain: "example.com"

config :pleroma, configurable_from_database: true
