defmodule Ratatouille.Renderer.Label do
  @moduledoc false

  alias Ratatouille.Renderer.{Canvas, Text}

  def render(%Canvas{} = canvas, %{content: text}, _children) do
    canvas
    |> Text.render(canvas.box.top_left, text)
    |> Canvas.consume_rows(1)
  end

  def render(%Canvas{} = canvas, _attrs, children) do
    Text.render_group(canvas, children)
  end
end
