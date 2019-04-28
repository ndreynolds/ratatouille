defmodule Ratatouille.Renderer.Element.Label do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Box, Canvas, Element, Text}

  def render(
        %Canvas{render_box: box} = canvas,
        %Element{attributes: %{content: text, wrap: true} = attrs} = el,
        render_fn
      ) do
    wrapped_text = wrap_lines(text, Box.width(box))

    render(
      canvas,
      %Element{el | attributes: %{attrs | content: wrapped_text, wrap: false}},
      render_fn
    )
  end

  def render(
        %Canvas{} = canvas,
        %Element{attributes: %{content: text} = attrs},
        _render_fn
      ) do
    lines = String.split(text, "\n")

    Enum.reduce(lines, canvas, fn line, acc_canvas ->
      acc_canvas
      |> Text.render(acc_canvas.render_box.top_left, line, attrs)
      |> Canvas.consume_rows(1)
    end)
  end

  def render(
        %Canvas{} = canvas,
        %Element{attributes: attrs, children: children},
        _render_fn
      ) do
    canvas
    |> Text.render_group(children, attrs)
    |> Canvas.consume_rows(1)
  end

  defp wrap_lines(text, columns) do
    words_with_size =
      for word <- String.split(text, " ") do
        {word, String.length(word)}
      end

    wrap(words_with_size, "", 0, columns)
  end

  defp wrap([], acc, _col, _col_max) do
    acc
  end

  defp wrap([{word, size} | rest], acc, col, col_max)
       when size + 1 < col_max - col do
    wrap(rest, acc <> word <> " ", col + size + 1, col_max)
  end

  defp wrap([{word, size} | rest], acc, _col, col_max) do
    wrap(rest, acc <> "\n" <> word <> " ", size + 1, col_max)
  end
end
