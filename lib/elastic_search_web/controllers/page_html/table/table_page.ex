defmodule ElasticSearchWeb.PageHtml.TablePage do
  @moduledoc false
  use ElasticSearchWeb, :surface_live_view
  alias Moon.Design.{Modal, Form, Form.Field, Form.Input, Button, Table, Table.Column}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
