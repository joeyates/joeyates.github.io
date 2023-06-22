import Mix.Config

config :fermo, :base_url, System.fetch_env!("BASE_URL")
