defmodule ElasticSearchWeb.PageHtml.TablePage do
  @moduledoc false
  use ElasticSearchWeb, :surface_live_view
  alias Moon.Design.{Modal, Form, Form.Field, Form.Input, Button, Table, Table.Column}

  alias ElasticSearch.Schemas.Article
  alias ElasticSearch.Repository.ArticleRepository

  data(keep_insert_dialog_open, :boolean, default: false)
  data(keep_change_dialog_open, :boolean, default: false)
  data(gender_options, :list, default: [%{key: "Published", value: true}, %{key: "Unpublished", value: false}])
  data(form_insert_changeset, :any, default: nil)

  data(form_change_changeset, :any, default: nil)

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> fetch_articles()}
  end

  def handle_event("set_open_insert_dialog", _, socket) do
    Modal.open("insert_modal")

    {:noreply,
     socket
     |> assign(keep_insert_dialog_open: true)
     |> assign(
       form_insert_changeset:
         Article.changeset(
           %Article{author_name: nil, status: false, tags: nil, label: nil},
           %{},
           false
         )
     )}
  end

  def handle_event("set_close_insert_dialog", _, socket) do
    Modal.close("insert_modal")

    {:noreply,
     socket
     |> assign(
       form_insert_changeset:
         Article.changeset(
           %Article{author_name: nil, status: false, tags: nil, label: nil},
           %{},
           false
         )
     )}
  end

  def handle_event(
        "validate_change_insert",
        %{
          "article" => %{
            "author_name" => author_name,
            "status" => status,
            "tags" => tags,
            "label" => label
          }
        },
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       form_insert_changeset:
         socket.assigns.form_insert_changeset.data
         |> Article.changeset(
           %{author_name: author_name, status: status, tags: tags, label: label},
           false
         )
         |> Map.put(:action, :insert)
     )}
  end

  def handle_event(
        "submit_add",
        %{
          "article" => %{
            "author_name" => author_name,
            "status" => status,
            "tags" => tags,
            "label" => label
          }
        },
        socket
      ) do
    validated_changeset =
      Article.changeset(
        %Article{author_name: nil, status: nil, tags: nil, label: nil},
        %{author_name: author_name, status: status, tags: tags, label: label},
        true
      )
      |> Map.put(:action, :insert)

    if(validated_changeset.valid?) do
      {:noreply, submit_add(author_name, status, tags, label, socket)}
    else
      {:noreply, cancel_add(validated_changeset, socket)}
    end
  end

  def handle_event("set_open_change_dialog", %{"value" => id}, socket) do
    Modal.open("change_modal")
    opened_article = ArticleRepository.get_article_by_id(id)

    {:noreply,
     socket
     |> assign(
       form_change_changeset:
         Article.changeset(
           %Article{
             author_name: opened_article.author_name,
             status: opened_article.status,
             tags: opened_article.tags,
             label: opened_article.label
           },
           %{},
           false
         )
     )
     |> assign(keep_change_dialog_open: true)
     |> assign(id_to_change: id)}
  end

  def handle_event(
        "validate_change",
        %{
          "article" => %{
            "author_name" => author_name,
            "status" => status,
            "tags" => tags,
            "label" => label
          }
        },
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       form_change_changeset:
         socket.assigns.form_change_changeset.data
         |> Article.changeset(
           %{author_name: author_name, status: status, tags: tags, label: label},
           false
         )
         |> Map.put(:action, :insert)
     )}
  end

  def handle_event("set_close_change_dialog", _, socket) do
    Modal.close("change_modal")

    {:noreply,
     socket
     |> assign(
       form_change_changeset:
         Article.changeset(
           %Article{author_name: nil, status: nil, tags: nil, label: nil},
           %{},
           false
         )
     )}
  end

  def handle_event(
        "submit_update",
        %{
          "article" => %{
            "author_name" => author_name,
            "status" => status,
            "tags" => tags,
            "label" => label
          }
        },
        socket
      ) do
    validated_changeset =
      Article.changeset(
        %Article{author_name: nil, status: nil, tags: nil, label: nil},
        %{author_name: author_name, status: status, tags: tags, label: label},
        true
      )
      |> Map.put(:action, :insert)

    if(validated_changeset.valid?) do
      {:noreply, submit_update(author_name, status, tags, label, socket)}
    else
      {:noreply, cancel_update(validated_changeset, socket)}
    end
  end

  def handle_event("submit_delete", _, socket) do
    Modal.close("change_modal")

    ArticleRepository.delete_article(socket.assigns.id_to_change)

    {:noreply,
     socket
     |> assign(keep_change_dialog_open: false)
     |> fetch_articles()}
  end

  defp submit_add(author_name, status, tags, label, socket) do
    Modal.close("insert_modal")

    ArticleRepository.create_article(%{
      author_name: author_name,
      status: status,
      tags: tags,
      label: label
    })

    socket
    |> fetch_articles()
  end

  defp cancel_add(validated_changeset, socket) do
    socket
    |> assign(form_insert_changeset: validated_changeset)
  end

  defp submit_update(author_name, status, tags, label, socket) do
    ArticleRepository.update_article(socket.assigns.id_to_change, %{
      author_name: author_name,
      status: status,
      tags: tags,
      label: label
    })

    Modal.close("change_modal")

    socket
    |> fetch_articles()
  end

  defp cancel_update(validated_changeset, socket) do
    socket
    |> assign(form_change_changeset: validated_changeset)
  end

  defp fetch_articles(socket) do
    socket
    |> assign(
      fields:
        ArticleRepository.fetch_articles() |> Enum.map(fn struct -> Map.from_struct(struct) end)
    )
  end
end
