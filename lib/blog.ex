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

  @categories_per_page 10
  @posts_per_page 10

  def config() do
    initial_config()
    |> add_category_related_pages()
    |> add_post_related_pages()
    |> then(&{:ok, &1})
  end

  defp add_category_related_pages(config) do
    {:ok, categories} = Blog.CMS.Category.fetch_all()

    categories = Enum.sort_by(categories, &String.downcase(&1.name))

    add_paginated_categories(config, categories)
  end

  defp add_paginated_categories(config, categories) do
    category_count = length(categories)
    page_count = Kernel.div(category_count - 1, @categories_per_page) + 1
    last = page_count - 1

    categories
    |> Enum.chunk_every(@categories_per_page)
    |> Enum.with_index()
    |> Enum.reduce(
      config,
      fn {categories_chunk, index}, config ->
        path = categories_path(index)

        previous =
          if index == 0 do
            nil
          else
            categories_path(index - 1)
          end

        next =
          if index == last do
            nil
          else
            categories_path(index + 1)
          end

        page(
          config,
          "/templates/categories.html.slim",
          path,
          %{
            categories: categories_chunk,
            previous: previous,
            next: next,
            page_count: page_count
          }
        )
      end
    )
  end

  defp add_post_related_pages(config) do
    posts = fetch_posts()

    config
    |> add_home_page(posts)
    |> add_paginated_posts(posts)
    |> add_posts(posts)
  end

  defp fetch_posts() do
    show_unpublished = Mix.env() == :dev
    {:ok, posts} = Blog.CMS.Post.fetch_all(only_published: !show_unpublished)

    posts
    |> optionally_add_published_on(show_unpublished)
    |> Enum.sort_by(&Date.to_iso8601(&1.published_on))
    |> Enum.reverse()
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

  defp add_paginated_posts(config, posts) do
    post_count = length(posts)
    page_count = Kernel.div(post_count - 1, @posts_per_page) + 1
    last = page_count - 1

    posts
    |> Enum.chunk_every(@posts_per_page)
    |> Enum.with_index()
    |> Enum.reduce(
      config,
      fn {posts_chunk, index}, config ->
        path = posts_path(index)

        previous =
          if index == 0 do
            nil
          else
            posts_path(index - 1)
          end

        next =
          if index == last do
            nil
          else
            posts_path(index + 1)
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

  defp posts_path(index) do
    if index == 0 do
      "/posts/"
    else
      "/posts/#{index + 1}/"
    end
  end

  defp categories_path(index) do
    if index == 0 do
      "/categories/"
    else
      "/categories/#{index + 1}/"
    end
  end

  defp optionally_add_published_on(posts, show_unpublished) do
    if show_unpublished do
      Enum.map(posts, fn post ->
        Map.put(post, :published_on, post.published_on || Date.utc_today())
      end)
    else
      posts
    end
  end
end
