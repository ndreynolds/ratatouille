defmodule ExTermbox.Renderer do
  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Element, Box, Table, View, Utils}

  def render(%Box{} = box, %View{root_element: el}) do
    render_tree(box, el)
  end

  def render_tree(%Box{}, []), do: []

  def render_tree(%Box{} = box, [%Element{} = el | rest]) do
    [render_tree(box, el) | render_tree(box, rest)]
  end

  def render_tree(%Box{} = box, %Element{
        tag: tag,
        attributes: attrs,
        children: children
      }) do
    case tag do
      :column_layout ->
        children
        |> Enum.zip(column_boxes(box, length(children)))
        |> Enum.map(fn {el, box} -> render_tree(box, el) end)

      :panel ->
        outer_box = Box.padded(box, 1)
        inner_box = Box.padded(outer_box, 1)

        outer_box
        |> Utils.render_border()

        outer_box.top_left
        |> Position.translate_x(2)
        |> Utils.render_text(attrs.title)

        inner_box
        |> render_tree(children)

      :table ->
        box
        |> Box.padded(1)
        |> Table.render(children)
    end
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
