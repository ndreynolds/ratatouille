defmodule Ratatouille.Renderer.Text do
  @moduledoc """
  Primitives for rendering text
  """

  alias ExTermbox.{Cell, Constants, Position}
  alias Ratatouille.Renderer.{Canvas, Element, Utils}

  def render(canvas, %Position{} = position, text, attrs \\ %{})
      when is_binary(text) do
    template = template_cell(attrs)
    cell_gen = Utils.cell_generator(position, :horizontal, template)

    cells =
      text
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(cell_gen)

    Canvas.merge_cells(canvas, cells)
  end

  def render_group(canvas, text_elements, attrs \\ %{}) do
    rendered_canvas =
      Enum.reduce(text_elements, canvas, fn el, canvas ->
        element = %Element{el | attributes: Map.merge(attrs, el.attributes)}
        render_group_member(canvas, element)
      end)

    %Canvas{rendered_canvas | render_box: canvas.render_box}
  end

  defp render_group_member(
         canvas,
         %Element{tag: :text, attributes: attrs, children: []}
       ) do
    text = attrs[:content] || ""

    canvas
    |> render(canvas.render_box.top_left, text, attrs)
    |> Canvas.translate(String.length(text), 0)
  end

  defp template_cell(attrs) do
    %Cell{
      bg: attrs[:background] || Constants.color(:default),
      fg: Utils.cell_foreground(attrs),
      ch: nil,
      position: nil
    }
  end
end
