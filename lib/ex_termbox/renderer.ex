defmodule ExTermbox.Renderer do
  @moduledoc """
  Logic to render a view tree.

  This API is still under development.
  """

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{
    Element,
    Box,
    Canvas,
    Panel,
    Sparkline,
    Table,
    View
  }

  def render(%Canvas{} = canvas, %View{root: el}),
    do: render_tree(canvas, el)

  defp render_tree(%Canvas{} = canvas, elements) when is_list(elements) do
    elements
    |> Enum.reduce(canvas, fn el, new_canvas -> render_tree(new_canvas, el) end)
  end

  defp render_tree(%Canvas{} = canvas, %Element{
        tag: tag,
        attributes: attrs,
        children: children
      }) do
    case tag do
      :columned_layout ->
        canvas
        |> render_columns(children)

      :panel ->
        canvas
        |> Panel.render(attrs.title)
        |> render_tree(children)

      :table ->
        canvas
        |> Table.render(children)

      :sparkline ->
        canvas
        |> Sparkline.render(children)
    end
  end

  defp render_columns(%Canvas{box: box} = canvas, children) do
    children
    |> Enum.zip(column_boxes(box, length(children)))
    |> Enum.reduce(canvas, fn({el, box}, new_canvas) ->
         render_tree(%Canvas{new_canvas | box: box}, el)
       end)
  end

  defp column_boxes(outer_box, num_columns) do
    col_width = Integer.floor_div(Box.width(outer_box), num_columns)

    0..num_columns
    |> Enum.map(&column_box(outer_box, col_width, &1))
  end

  defp column_box(outer_box, col_width, col_idx) do
    Box.from_dimensions(
      col_width,
      Box.height(outer_box),
      Position.translate_x(outer_box.top_left, col_width * col_idx)
    )
  end
end
