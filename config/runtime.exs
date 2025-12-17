import Config

imgproxy_base_url =
  System.get_env("IMGPROXY_BASE_URL") ||
    raise """
    environment variable IMGPROXY_BASE_URL is missing.
    For example: https://my-imgproxy-domain.com
    """

imgproxy_key =
  System.get_env("IMGPROXY_KEY") ||
    raise """
    environment variable IMGPROXY_KEY is missing.
    You can generate one by calling: mix imgproxy.gen.secret
    """

imgproxy_salt =
  System.get_env("IMGPROXY_SALT") ||
    raise """
    environment variable IMGPROXY_SALT is missing.
    You can generate one by calling: mix imgproxy.gen.secret
    """

config :imgproxy,
  prefix: imgproxy_base_url,
  key: imgproxy_key,
  salt: imgproxy_salt

basic_auth_user =
  System.get_env("BLOG_CMS_BASIC_AUTH_USER") ||
    raise """
    environment variable BLOG_CMS_BASIC_AUTH_USER is missing.
    """

basic_auth_password =
  System.get_env("BLOG_CMS_BASIC_AUTH_PASSWORD") ||
    raise """
    environment variable BLOG_CMS_BASIC_AUTH_PASSWORD is missing.
    """

payloadcms_graphql_endpoint =
  System.get_env("BLOG_CMS_GRAPHQL_ENDPOINT") ||
    raise """
    environment variable BLOG_CMS_GRAPHQL_ENDPOINT is missing.
    """

config :payloadcms_graphql_client,
  basic_auth_user: basic_auth_user,
  basic_auth_password: basic_auth_password,
  endpoint: payloadcms_graphql_endpoint
