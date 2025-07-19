import Config

payloadcms_api_key =
  System.get_env("PAYLOADCMS_API_KEY") ||
    raise """
    environment variable PAYLOADCMS_API_KEY is missing.
    """

payloadcms_graphql_endpoint =
  System.get_env("PAYLOADCMS_GRAPHQL_ENDPOINT") ||
    raise """
    environment variable PAYLOADCMS_GRAPHQL_ENDPOINT is missing.
    """

config :payloadcms_graphql_client,
  api_key: payloadcms_api_key,
  endpoint: payloadcms_graphql_endpoint

config :fermo, :base_url, System.fetch_env!("BASE_URL")
