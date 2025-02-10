defmodule ElasticSearchWeb.ElasticSearchWebTest do
  use ElasticSearchWeb.ConnCase, async: false
  alias ElasticSearch.Repository.{ArticleRepository}
  import Phoenix.LiveViewTest

  describe "Web test" do
    setup do
      conn = build_conn()

      article =
        ArticleRepository.create_article(%{
          author_name: "custom_author_name_test",
          status: false,
          tags: "custom_tag_test",
          label: "(url_test)"
        })

      {:ok, view, _html} = live(conn, ~p"/table")
      {:ok, conn: conn, view: view, article: article}
    end

    test "renders the page", %{view: view} do
      assert has_element?(view, "table")
    end

    test "add field event", %{view: view} do
      view
      |> element("button[phx-click]", "Insert new data")
      |> render_click()

      assert render(view) =~ "Add new field to article"

      view
      |> form("form#insert-form",
        article: %{
          author_name: "Author_name_test22",
          status: false,
          tags: "Tags_test",
          label: "(url)"
        }
      )
      |> render_change()

      view |> form("form#insert-form") |> render_submit()

      assert render(view) =~ "Author_name_test22"
      assert render(view) =~ "Tags_test"
    end

    test "update field event", %{view: view, article: article} do
      view
      |> element("button[phx-click='set_open_change_dialog'][value='#{article.id}']", "Change")
      |> render_click()

      assert render(view) =~ "Update field"

      view
      |> form("form#update-form",
        article: %{
          author_name: "Author_name_test22",
          status: false,
          tags: "Tags_test",
          label: "(url)"
        }
      )
      |> render_change()

      view |> form("form#update-form") |> render_submit()

      assert render(view) =~ "Author_name_test22"
      assert render(view) =~ "Tags_test"
    end
  end
end
