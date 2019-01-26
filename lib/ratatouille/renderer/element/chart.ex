defmodule Ratatouille.Renderer.Element.Chart do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  # TODO: Replace Asciichart with more featureful plotter.

  alias ExTermbox.Position
  alias Ratatouille.Renderer.{Canvas, Element, Text}

  def render(
        %Canvas{render_box: box} = canvas,
        %Element{attributes: %{type: :line, series: series} = attrs},
        _render_fn
      ) do
    chart_opts = Map.take(attrs, [:height, :offset, :padding])
    normalized_series = normalize_series(series)

    case plot(normalized_series, chart_opts) do
      {:ok, chart} ->
        render_chart(canvas, chart)

      {:error, error} ->
        canvas
        |> Text.render(box.top_left, "Chart render error: " <> inspect(error))
        |> Canvas.consume_rows(1)
    end
  end

  defp render_chart(%Canvas{render_box: box} = canvas, chart) do
    lines = String.split(chart, "\n")

    lines
    |> Enum.with_index()
    |> Enum.reduce(canvas, fn {line, idx}, acc ->
      position = Position.translate_y(box.top_left, idx)

      acc
      |> Text.render(position, line)
      |> Canvas.consume_rows(1)
    end)
  end

  defp plot(series, opts) do
    Asciichart.plot(series, opts)
  rescue
    _ -> {:error, :plot_error}
  end

  # Work around some hard arithmetic errors in asciichart with certain inputs
  defp normalize_series([x]), do: [0, x]
  defp normalize_series([x, x]), do: [0, x, x]
  defp normalize_series(other), do: other
end
