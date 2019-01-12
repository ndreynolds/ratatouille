defmodule ExTermbox.Renderer.Chart do
  @moduledoc false

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Canvas, Text}

  def render(%Canvas{box: box} = canvas, %{type: :line, series: series} = attrs) do
    chart_opts = Map.take(attrs, [:height, :offset, :padding])

    case Asciichart.plot(series, chart_opts) do
      {:ok, chart} ->
        render_chart(canvas, chart)

      {:error, error} ->
        canvas
        |> Text.render(box.top_left, "Chart render error")
        |> Canvas.consume_rows(1)
    end
  end

  defp render_chart(%Canvas{box: box} = canvas, chart) do
    lines = String.split(chart, "\n")

    lines
    |> Enum.with_index()
    |> Enum.reduce(canvas, fn {line, idx}, acc ->
      position = Position.translate_y(box.top_left, idx)
      Text.render(acc, position, line)
    end)
    |> Canvas.consume_rows(length(lines))
  end
end
