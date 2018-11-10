defmodule ExTermbox.Renderer.Panel do
  @moduledoc false

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Border, Box, Canvas, Text}

  @padding 2
  @title_offset_x 2

  def render(%Canvas{box: box} = canvas, %{height: :fill} = attrs, inner_fn) do
    merged_attrs = Map.merge(attrs, %{height: Box.height(box)})
    render(canvas, merged_attrs, inner_fn)
  end

  def render(%Canvas{box: box} = canvas, attrs, inner_fn) do
    fill_empty? = !is_nil(attrs[:height])

    constrained_canvas =
      canvas
      |> constrain_canvas(attrs[:height])

    rendered_canvas =
      constrained_canvas
      |> render_children(inner_fn)

    consume_y = rendered_canvas.box.top_left.y - box.top_left.y + @padding

    constrained_canvas
    |> wrapper_canvas(rendered_canvas, fill_empty?)
    |> render_features(attrs)
    |> Canvas.consume(0, consume_y)
  end

  defp render_children(canvas, render_fn) do
    canvas
    |> Canvas.padded(@padding)
    |> render_fn.()
  end

  defp render_features(canvas, attrs) do
    canvas
    |> Border.render()
    |> render_title(attrs[:title])
  end

  defp render_title(canvas, nil), do: canvas

  defp render_title(%Canvas{box: box} = canvas, title) do
    Text.render(canvas, title_position(box), title)
  end

  defp title_position(box),
    do: Position.translate_x(box.top_left, @title_offset_x)

  defp wrapper_canvas(original_canvas, rendered_canvas, fill?) do
    %Canvas{
      rendered_canvas
      | box: wrapper_box(original_canvas.box, rendered_canvas.box, fill?)
    }
  end

  defp wrapper_box(original_box, _rendered_box, true), do: original_box

  defp wrapper_box(original_box, rendered_box, false),
    do: %Box{original_box | bottom_right: Box.top_right(rendered_box)}

  defp constrain_canvas(%Canvas{box: box} = canvas, height),
    do: %Canvas{canvas | box: constrain_box(box, height)}

  defp constrain_box(box, nil), do: box

  defp constrain_box(%Box{top_left: top_left} = box, height) do
    Box.from_dimensions(Box.width(box), height, top_left)
  end
end
