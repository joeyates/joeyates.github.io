defmodule Blog do
  @moduledoc """
  Documentation for `Blog`.
  """

  @statics ~w(
    android-chrome-192x192.png
    android-chrome-512x512.png
    apple-touch-icon.png
    CNAME
    favicon-16x16.png
    favicon-32x32.png
    favicon.ico
    robots.txt
    site.webmanifest
  )

  use Fermo, %{
    base_url: Application.compile_env!(:fermo, :base_url),
    i18n: [:en],
    localized_paths: true,
    exclude: ["templates/*", "layouts/*", "javascripts/*", "stylesheets/*"],
    sitemap: %{},
    statics: Enum.map(@statics, &%{source: &1, filename: &1})
  }

  import Fermo, only: [page: 4]

  @per_page 20

  def config do
    posts =
      Blog.CMS.Post.fetch_all()
      |> Enum.sort_by(&Date.to_iso8601(&1.published_on))
      |> Enum.reverse()

    config =
      initial_config()
      |> add_home_page(posts)
      |> add_paginated(posts)
      |> add_posts(posts)

    {:ok, config}
  end

  defp add_home_page(config, posts) do
    latest = hd(posts)
    oldest = List.last(posts)
    full_year_range = "#{oldest.published_on.year} - #{latest.published_on.year}"
    most_recent_posts = Enum.take(posts, 15)

    page(
      config,
      "/templates/home.html.slim",
      "/",
      %{
        posts: most_recent_posts,
        full_year_range: full_year_range
      }
    )
  end

  defp add_posts(config, posts) do
    paths = Enum.map(posts, &"/posts/#{&1.slug}/")
    previous_paths = [nil | Enum.slice(paths, 0..-2//1)]
    next_paths = Enum.slice(paths, 1..-1//1) ++ [nil]

    {config, _previous_paths, _next_paths} =
      Enum.reduce(
        posts,
        {config, previous_paths, next_paths},
        fn post, {config, previous_paths, next_paths} ->
          [previous | previous_paths] = previous_paths
          [next | next_paths] = next_paths

          config =
            page(
              config,
              "/templates/post.html.slim",
              "/posts/#{post.slug}/",
              %{
                post: post,
                previous: previous,
                next: next
              }
            )

          {config, previous_paths, next_paths}
        end
      )

    config
  end

  defp add_paginated(config, posts) do
    post_count = length(posts)
    page_count = Kernel.div(post_count - 1, @per_page) + 1
    last = page_count - 1

    posts
    |> Enum.chunk_every(@per_page)
    |> Enum.with_index()
    |> Enum.reduce(
      config,
      fn {posts_chunk, index}, config ->
        path = index_page_path(index)

        previous =
          if index == 0 do
            nil
          else
            index_page_path(index - 1)
          end

        next =
          if index == last do
            nil
          else
            index_page_path(index + 1)
          end

        most_recent_year = hd(posts_chunk).published_on.year
        least_recent_year = Enum.at(posts_chunk, -1).published_on.year

        year_range =
          if most_recent_year == least_recent_year do
            most_recent_year
          else
            "#{least_recent_year} - #{most_recent_year}"
          end

        page(
          config,
          "/templates/posts.html.slim",
          path,
          %{
            posts: posts_chunk,
            previous: previous,
            next: next,
            page_count: page_count,
            most_recent_year: most_recent_year,
            year_range: year_range
          }
        )
      end
    )
  end

  defp index_page_path(index) do
    if index == 0 do
      "/posts/"
    else
      "/posts/#{index + 1}/"
    end
  end
end
