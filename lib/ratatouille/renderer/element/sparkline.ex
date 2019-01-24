defmodule Ratatouille.Renderer.Element.Sparkline do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Canvas, Element, Text}

  @ticks ~w[▁ ▂ ▃ ▄ ▅ ▆ ▇ █]
  @range length(@ticks) - 1

  @impl true
  def render(
        %Canvas{} = canvas,
        %Element{attributes: %{series: [_ | _] = series}},
        _render_fn
      ) do
    text =
      series
      |> normalize()
      |> Enum.map(fn idx -> Enum.at(@ticks, idx) end)
      |> Enum.join()

    canvas
    |> Text.render(canvas.render_box.top_left, text)
    |> Canvas.consume_rows(1)
  end

  def render(%Canvas{} = canvas, _other, _render_fn), do: canvas

  defp normalize(values) do
    min = Enum.min(values)
    max = Enum.max(values)

    values
    |> Enum.map(&normalize({min, max}, &1))
  end

  defp normalize({min, max}, value) do
    x = (value - min) / (max - min)
    round(x * @range)
  end
end
