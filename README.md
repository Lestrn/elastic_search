# ElasticSearch

This project demonstrates how to integrate **Elasticsearch** with a **Phoenix (Elixir) application**, using **PostgreSQL** as the primary database. The application includes a page displaying a table of articles with the following attributes:

- **Article Title**
- **Author Name**
- **Status** (Published/Unpublished)
- **Tags**
- **Label** (URL to the article)

The application supports **CRUD operations** (Create, Read, Update, Delete) with **buttons and modals** for managing articles.

To start your Phoenix server:
  * Run `docker compose up` to start db and elastic search
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


##  Testing

  * MIX_ENV=test mix ecto.reset
  * mix test

  https://github.com/user-attachments/assets/bcee870a-7f89-4720-9471-8112947c5414
