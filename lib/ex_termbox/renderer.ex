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
    Text
  }

  def render(%Canvas{} = canvas, %Element{tag: :view, children: children}) do
    render_tree(canvas, children)
  end

  defp render_tree(%Canvas{} = canvas, elements) when is_list(elements) do
    elements
    |> Enum.reduce(canvas, fn el, new_canvas -> render_tree(new_canvas, el) end)
  end

  defp render_tree(%Canvas{box: box} = canvas, %Element{
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
        |> Panel.render(attrs.title, fn canvas ->
          render_tree(canvas, children)
        end)

      :table ->
        canvas
        |> Table.render(children)

      :sparkline ->
        canvas
        |> Sparkline.render(children)

      :status_bar ->
        new_box = %Box{
          box
          | top_left: %Position{box.top_left | y: box.bottom_right.y}
        }

        %Canvas{canvas | box: new_box}
        |> render_tree(children)

      :text ->
        canvas
        |> Text.render(canvas.box.top_left, Enum.at(children, 0), attrs)

      :text_group ->
        canvas
        |> Text.render_group(children)
    end
  end

  defp render_columns(%Canvas{box: box} = canvas, children) do
    children
    |> Enum.zip(column_boxes(box, length(children)))
    |> Enum.reduce(canvas, fn {el, box}, new_canvas ->
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
