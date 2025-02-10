defmodule ElasticSearch.ElasticSearchTest do
  alias ElasticSearch.{Repo}
  alias ElasticSearch.Repository.{ArticleRepository, ApiElasticSearch}
  alias ElasticSearch.Schemas.Article
  use ElasticSearch.DataCase, async: false

  @index_name "article_index_test"

  # Important before running tests MIX_ENV=test mix ecto.reset
  describe "Repository db test, elastic search relation" do
    setup do
      Repo.delete_all(Article)

      articles =
        Enum.map(1..10, fn i ->
          %Article{
            author_name: "Author_name_test_#{i}",
            status: Enum.random([true, false]),
            tags: "Tags_test_#{i}",
            label: "(url) #{i}"
          }
          |> Repo.insert!()
        end)

      ApiElasticSearch.maybe_create_index(@index_name)
      {:ok, _bulk_response} = ApiElasticSearch.bulk_index_articles(@index_name)

      {:ok, %{articles: articles}}
    end

    test "Elastic search bulk data success" do
      assert ApiElasticSearch.search("*", "*", @index_name) |> Enum.count() == 10
    end

    test "Adding data to database adds article to elastic search as well" do
      article = ArticleRepository.create_article(%{author_name: "test_add_name", label: "test_label", status: false, tags: "gg gg"}, @index_name)
      {:ok, article_from_elastic_search} = ApiElasticSearch.get_article_by_id_elastic_search(article.id, @index_name)
      assert  Map.get(article_from_elastic_search, "_id") == article.id |> Integer.to_string()
    end

    test "Deleting data to database deletes article from elastic search as well", %{articles: articles} do
      article = hd(articles)
      ArticleRepository.delete_article(article.id, @index_name)
      {:ok, article_from_elastic_search} = ApiElasticSearch.get_article_by_id_elastic_search(article.id, @index_name)
      assert Map.get(article_from_elastic_search, "found") == false
    end

    test "Updating data in database also updates data in elastic search", %{articles: articles} do
      updated_article_attrs = hd(articles)
      |> Map.from_struct()
      |> Map.put(:author_name, "Updated author name")

      updated_article = ArticleRepository.update_article(updated_article_attrs.id, updated_article_attrs, @index_name)
      {:ok, article_from_elastic_search} = ApiElasticSearch.get_article_by_id_elastic_search(updated_article.id, @index_name)
      assert Map.get(article_from_elastic_search, "_source") |> Map.get("author_name") == updated_article.author_name
    end
  end
end
