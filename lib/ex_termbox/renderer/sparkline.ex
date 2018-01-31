defmodule ExTermbox.Renderer.Sparkline do
  @moduledoc false

  alias ExTermbox.Renderer.{Canvas, Utils}

  @ticks ~w[▁ ▂ ▃ ▄ ▅ ▆ ▇ █]
  @range length(@ticks) - 1

  def render(%Canvas{} = canvas, values) do
    text =
      values
      |> normalize()
      |> Enum.map(fn idx -> Enum.at(@ticks, idx) end)
      |> Enum.join()

    canvas
    |> Utils.render_text(canvas.box.top_left, text)
  end

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
