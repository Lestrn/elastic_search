# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElasticSearch.Repo.insert!(%ElasticSearch.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias ElasticSearch.Repo
alias ElasticSearch.Schemas.Article

# Generate 10 random articles
for _ <- 1..100 do
  article = %Article{
    author_name: Faker.Person.name(),
    status: Enum.random([true, false]),
    tags: Enum.join(Faker.Lorem.words(3), ", "),
    label: Faker.Lorem.sentence(2)
  }

  Repo.insert!(article)
end
