defmodule Blog do
  @moduledoc """
  Documentation for `Blog`.
  """

  @statics ~w(
    android-chrome-192x192.png
    android-chrome-512x512.png
    app.css
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

  use Helpers

  def config do
    DatoCMS.setup()

    config = initial_config()

    config =
      page(
        config,
        "/templates/home.html.slim",
        "/index.html",
        %{id: "home", path: "/"}
      )

    config = add_posts(config)

    {:ok, config}
  end

  defp add_posts(config) do
    post_count = DatoCMS.Post.count(published: Mix.env() != :dev)
    index_page_count = Kernel.div(post_count - 1, DatoCMS.Post.per_page()) + 1

    Enum.reduce(
      1..index_page_count,
      config,
      fn i, acc ->
        index_path = if i == 1, do: "/posts/index.html", else: "/posts/#{i}/index.html"

        acc =
          page(
            acc,
            "/templates/posts.html.slim",
            index_path,
            %{
              id: "posts##{i}",
              page: i,
              path: index_path,
              page_count: index_page_count
            }
          )

        posts = DatoCMS.Post.page(nil, page: i, published: Mix.env() != :dev)

        posts
        |> Enum.with_index()
        |> Enum.reduce(
          acc,
          fn {post, j}, acc1 ->
            previous = if j > 0, do: Enum.at(posts, j - 1)
            next = Enum.at(posts, j + 1)

            acc1 =
              page(
                acc1,
                "/templates/post.html.slim",
                "/posts/#{post.slug}/index.html",
                %{
                  id: post.id,
                  previous: previous,
                  next: next
                }
              )

            if post.old_path == "" do
              acc1
            else
              page(
                acc1,
                "/templates/redirect.html.slim",
                "#{post.old_path}index.html",
                %{id: "redirect_#{post.id}", location: "/posts/#{post.slug}/"}
              )
            end
          end
        )
      end
    )
  end
end
