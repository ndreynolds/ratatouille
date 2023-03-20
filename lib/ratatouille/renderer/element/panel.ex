defmodule Ratatouille.Renderer.Element.Panel do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias ExTermbox.Position
  alias Ratatouille.Renderer.{Border, Box, Canvas, Element, Text}

  @default_padding 1
  @border_width 1
  @margin_y 1
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
    constrained_canvas = constrain_canvas(canvas, attrs[:height])

    padding = (attrs[:padding] || @default_padding) + @border_width

    top = if attrs[:top], do: attrs[:top] + @border_width, else: padding
    left = if attrs[:left], do: attrs[:left] + @border_width, else: padding
    bottom = if attrs[:bottom], do: attrs[:bottom] + @border_width, else: padding
    right = if attrs[:right], do: attrs[:right] + @border_width, else: padding

    rendered_canvas =
      constrained_canvas
      |> Canvas.padded(top: top, left: left, bottom: bottom, right: right)
      |> render_fn.(children)
      |> wrapper_canvas(constrained_canvas, fill_empty?)
      |> render_features(attrs)

    %Canvas{
      rendered_canvas
      | render_box: %Box{
          box
          | top_left: %Position{
              x: box.top_left.x,
              y: rendered_canvas.render_box.bottom_right.y + @margin_y
            }
        }
    }
  end

  defp render_features(canvas, attrs) do
    canvas
    |> Border.render(attrs[:border])
    |> render_title(attrs)
  end

  defp render_title(canvas, nil), do: canvas

  defp render_title(%Canvas{render_box: box} = canvas, %{title: title} = attr)
       when is_binary(title) do
    Text.render(canvas, title_position(box), title, attr)
  end

  defp render_title(canvas, _), do: canvas

  defp title_position(box),
    do: Position.translate_x(box.top_left, @title_offset_x)

  defp wrapper_canvas(rendered_canvas, original_canvas, fill?) do
    %Canvas{
      rendered_canvas
      | render_box:
          wrapper_box(
            rendered_canvas.render_box,
            original_canvas.render_box,
            fill?
          )
    }
  end

  defp wrapper_box(_rendered_box, original_box, true), do: original_box

  defp wrapper_box(rendered_box, original_box, false),
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
