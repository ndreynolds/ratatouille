defmodule Ratatouille.Renderer.Element.ProgressBar do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias ExTermbox.Position

  alias Ratatouille.Renderer.{Box, Canvas, Element, Text}

  @fill_char "█"

  def render(%Canvas{render_box: box} = canvas, %Element{attributes: attrs}, _render_fn) do
    width = Box.width(box)
    bar_pieces = build_bar(width, attrs)

    bar_pieces
    |> Enum.reduce(canvas, fn {shift, str, attrs}, %Canvas{render_box: box} = canvas ->
      position = Position.translate_x(box.top_left, shift)
      Text.render(canvas, position, str, attrs)
    end)
    |> Canvas.consume_rows(1)
  end

  defp build_bar(width, %{percentage: percentage} = attrs) do
    percentage =
      percentage
      |> max(0)
      |> min(100)

    text_position = Map.get(attrs, :text_position, :right)
    text_color = Map.get(attrs, :text_color, :default)
    on_color = Map.get(attrs, :on_color, :default)
    off_color = Map.get(attrs, :off_color, :default)

    width = if(text_position == :none, do: width, else: width - 6)

    on = ceil(width / 100.0 * percentage)
    off = width - on

    on_string = String.duplicate(@fill_char, on)

    off_string =
      case off_color do
        :default -> ""
        _ -> String.duplicate(@fill_char, off)
      end

    case text_position do
      :none ->
        [
          {0, on_string, color: on_color},
          {on, off_string, color: off_color}
        ]

      :left ->
        [
          {0, String.pad_leading("#{percentage} % ", 6), color: text_color},
          {6, on_string, color: on_color},
          {6 + on, off_string, color: off_color}
        ]

      _ ->
        [
          {0, on_string, color: on_color},
          {on, off_string, color: off_color},
          {on + off, String.pad_leading("#{percentage} %", 6), color: text_color}
        ]
    end
  end
end
