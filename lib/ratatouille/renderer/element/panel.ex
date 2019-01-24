defmodule Ratatouille.Renderer.Element.Panel do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias ExTermbox.Position
  alias Ratatouille.Renderer.{Border, Box, Canvas, Element, Text}

  @padding 2
  @title_offset_x 2

  @impl true
  def render(
        %Canvas{render_box: box} = canvas,
        %Element{attributes: %{height: :fill} = attrs} = element,
        render_fn
      ) do
    new_attrs = %{attrs | height: Box.height(box)}

    render(canvas, %Element{element | attributes: new_attrs}, render_fn)
  end

  def render(
        %Canvas{render_box: box} = canvas,
        %Element{attributes: attrs, children: children},
        render_fn
      ) do
    fill_empty? = !is_nil(attrs[:height])

    constrained_canvas =
      canvas
      |> constrain_canvas(attrs[:height])

    rendered_canvas =
      constrained_canvas
      |> Canvas.padded(@padding)
      |> render_fn.(children)

    consume_y =
      rendered_canvas.render_box.top_left.y - box.top_left.y + @padding

    constrained_canvas
    |> wrapper_canvas(rendered_canvas, fill_empty?)
    |> render_features(attrs)
    |> Canvas.consume_rows(consume_y)
  end

  defp render_features(canvas, attrs) do
    canvas
    |> Border.render()
    |> render_title(attrs[:title])
  end

  defp render_title(canvas, nil), do: canvas

  defp render_title(%Canvas{render_box: box} = canvas, title) do
    Text.render(canvas, title_position(box), title)
  end

  defp title_position(box),
    do: Position.translate_x(box.top_left, @title_offset_x)

  defp wrapper_canvas(original_canvas, rendered_canvas, fill?) do
    %Canvas{
      rendered_canvas
      | render_box:
          wrapper_box(
            original_canvas.render_box,
            rendered_canvas.render_box,
            fill?
          )
    }
  end

  defp wrapper_box(original_box, _rendered_box, true), do: original_box

  defp wrapper_box(original_box, rendered_box, false),
    do: %Box{
      original_box
      | bottom_right: %Position{
          x: original_box.bottom_right.x,
          y: rendered_box.top_left.y
        }
    }

  defp constrain_canvas(%Canvas{render_box: box} = canvas, height),
    do: %Canvas{canvas | render_box: constrain_box(box, height)}

  defp constrain_box(box, nil), do: box

  defp constrain_box(%Box{top_left: top_left} = box, height) do
    Box.from_dimensions(Box.width(box), height, top_left)
  end
end
