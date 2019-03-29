defmodule Ratatouille.Renderer.Text do
  @moduledoc """
  Primitives for rendering text
  """

  alias ExTermbox.{Cell, Position}
  alias Ratatouille.Renderer.{Canvas, Cells, Element}

  def render(canvas, %Position{} = position, text, attrs \\ %{})
      when is_binary(text) do
    template = template_cell(attrs)
    cell_generator = Cells.generator(position, :horizontal, template)

    cells =
      text
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(cell_generator)

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
      bg: Cells.background(attrs),
      fg: Cells.foreground(attrs),
      ch: nil,
      position: nil
    }
  end
end
