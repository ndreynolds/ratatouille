# This example shows how to render and scroll multi-line content, as
# well as how to asynchronously perform updates, by implementing a
# documentation browser for Elixir modules.
#
# The browser is intended to be relatively simplistic for the sake of
# readability. But it might be fun to add:
#
#  - Searching
#  - Text reflowing at narrow screen widths
#  - Markdown formatting
#  - Code highlighting
#  - vi-style pagination shortcuts (gg, G, etc.)
#
# Run this example with:
#
#   mix run examples/documentation_browser.exs

defmodule DocumentationBrowser do
  @behaviour Ratatouille.App

  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  alias Ratatouille.Runtime.Command

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @header "Documentation Browser Example (UP/DOWN to select module, j/k to scroll content)"

  def init(_context) do
    {:ok, modules} = :application.get_key(:elixir, :modules)

    model = %{
      content: "",
      content_cursor: 0,
      module_cursor: 0,
      modules: modules
    }

    {model, update_cmd(model)}
  end

  def update(
        %{
          content_cursor: content_cursor,
          module_cursor: module_cursor,
          modules: modules
        } = model,
        msg
      ) do
    case msg do
      {:event, %{ch: ?k}} ->
        %{model | content_cursor: max(content_cursor - 1, 0)}

      {:event, %{ch: ?j}} ->
        %{model | content_cursor: content_cursor + 1}

      {:event, %{key: key}} when key in [@arrow_up, @arrow_down] ->
        new_cursor =
          case key do
            @arrow_up -> max(module_cursor - 1, 0)
            @arrow_down -> min(module_cursor + 1, length(modules) - 1)
          end

        new_model = %{model | module_cursor: new_cursor}
        {new_model, update_cmd(new_model)}

      {:content_updated, content} ->
        %{model | content: content}

      _ ->
        model
    end
  end

  def render(model) do
    selected = Enum.at(model.modules, model.module_cursor)

    menu_bar =
      bar do
        label(content: @header, color: :blue)
      end

    view(top_bar: menu_bar) do
      row do
        column(size: 3) do
          panel(title: "Modules", height: :fill) do
            viewport(offset_y: model.module_cursor) do
              for {module, idx} <- Enum.with_index(model.modules) do
                if idx == model.module_cursor do
                  label(content: "> " <> inspect(module), attributes: [:bold])
                else
                  label(content: inspect(module))
                end
              end
            end
          end
        end

        column(size: 9) do
          panel(title: inspect(selected), height: :fill) do
            viewport(offset_y: model.content_cursor) do
              label(content: model.content)
            end
          end
        end
      end
    end
  end

  defp update_cmd(model) do
    Command.new(fn -> fetch_content(model) end, :content_updated)
  end

  defp fetch_content(%{module_cursor: cursor, modules: modules}) do
    selected = Enum.at(modules, cursor)

    case Code.fetch_docs(selected) do
      {:docs_v1, _, :elixir, _, %{"en" => docs}, _, _} ->
        docs

      _ ->
        "(No documentation for #{selected})"
    end
  end
end

Ratatouille.run(DocumentationBrowser)
