defmodule JoeyatesBlog do
  @moduledoc """
  Documentation for `JoeyatesBlog`.
  """

  use Fermo, %{
    base_url: Application.compile_env!(:fermo, :base_url),
    i18n: [:en],
    localized_paths: true,
    exclude: ["templates/*", "layouts/*", "javascripts/*", "stylesheets/*"]
  }
  import Fermo, only: [page: 4]

  use Helpers

  def config do
    CMS.setup()

    config = initial_config()

    config = page(
      config,
      "/templates/home.html.slim",
      "/index.html",
      %{id: "home", path: "/"}
    )

    config = Fermo.Config.add_static(config, "CNAME", "CNAME")

    config = add_posts(config)

    {:ok, config}
  end

  defp add_posts(config) do
    post_count = CMS.post_count()
    index_page_count = Kernel.div(post_count - 1, CMS.posts_per_page()) + 1

    Enum.reduce(
      1..index_page_count,
      config,
      fn i, acc ->
        index_path = if i == 1, do: "/posts/index.html", else: "/posts/#{i}/index.html"

        acc = page(
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

        Enum.reduce(
          CMS.posts_page(nil, page: i),
          acc,
          fn post, acc1 ->
            acc1 = page(
              acc1,
              "/templates/post.html.slim",
              "/posts/#{post.slug}/index.html",
              %{id: post.id}
            )

            if post.oldPath == "" do
              acc1
            else
              page(
                acc1,
                "/templates/redirect.html.slim",
                "#{post.oldPath}index.html",
                %{id: "redirect_#{post.id}", location: "/posts/#{post.slug}/"}
              )
            end
          end
        )
      end
    )
  end
end
