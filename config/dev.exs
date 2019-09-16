use Mix.Config

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :forrest_gump,
  interval: 500,
  batch_size: 10,
  redises: [
    {"127.0.0.1", 6379}
  ]

