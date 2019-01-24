defmodule Ratatouille.Renderer.Element.Bar do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Canvas, Element}

  @impl true
  def render(
        %Canvas{} = canvas,
        %Element{children: children},
        render_fn
      ) do
    render_fn.(canvas, children)
  end
end
