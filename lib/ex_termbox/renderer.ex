defmodule ExTermbox.Renderer do
  alias ExTermbox.{Bindings, Cell, Position}
  alias ExTermbox.Renderer.{Element, Box, View}

  def render(%Box{} = box, %View{root_element: el}) do
    render_tree(box, el)
  end

  def render_tree(%Box{}, []), do: []
  def render_tree(%Box{} = box, [%Element{} = el | rest]),
    do: [render_tree(box, el) | render_tree(box, rest)]

  def render_tree(%Box{} = box,
                   %Element{tag: tag, attributes: attrs, children: children}) do
    case tag do
      :column_layout ->
        num_columns = length(children)
        column_width = Integer.floor_div(Box.width(box), num_columns)
        children
        |> Enum.with_index()
        |> Enum.map(
             fn {el, idx} ->
               render_tree(Box.translate(box, column_width * idx, 0), el)
             end
           )
      :panel ->
        render_text(box.top_left, attrs.title)
    end
  end

  # defp render_tree(%Window{} = window, %Element{tag: :column_layout, children: children}),
  #   do: render_tree(window, children)

  # defp render_tree(%Window{} = window, elements) when is_list(elements),
  #   do: Enum.map(elements, &(render_tree(window, &1)))

  # defp render_tree(:column_layout, attributes, children) do
  # end

  def render_text(%Position{} = position, text) do
    chars = String.graphemes(text)

    chars
    |> Enum.with_index()
    |> Enum.map(fn {char_str, idx} ->
      pos = Position.translate(position, idx, 0)
      <<char::utf8>> = char_str
      %Cell{position: pos, char: char}
    end)
    |> Enum.each(&render_cell/1)
  end

  defp render_cell(%Cell{} = cell) do
    Bindings.put_cell(cell)
  end
end
