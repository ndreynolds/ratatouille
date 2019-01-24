defmodule Ratatouille.Renderer.Element.Overlay do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Canvas, Element}

  @impl true
  def render(
        %Canvas{outer_box: outer_box} = canvas,
        %Element{attributes: attrs, children: children},
        render_fn
      ) do
    padding = attrs[:padding] || 10

    canvas
    |> Canvas.put_box(outer_box)
    |> Canvas.padded(padding)
    |> Canvas.fill_background()
    |> render_fn.(children)
  end
end
