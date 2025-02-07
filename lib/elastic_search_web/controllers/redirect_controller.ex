defmodule ElasticSearchWeb.RedirectController do
  use ElasticSearchWeb, :controller

  def to_table(conn, _params) do
    redirect(conn, to: "/table")
  end
end
