defmodule Ratatouille.Renderer.Element.Overlay do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Canvas, Element}

  @default_padding 10

  @impl true
  def render(
        %Canvas{outer_box: outer_box} = canvas,
        %Element{attributes: attrs, children: children},
        render_fn
      ) do

    padding = attrs[:padding] || @default_padding
    top = attrs[:top] || padding
    left = attrs[:left] || padding
    bottom = attrs[:bottom] || padding
    right = attrs[:right] || padding

    canvas
    |> Canvas.put_box(outer_box)
    |> Canvas.padded(top: top, left: left, bottom: bottom, right: right)
    |> Canvas.fill_background()
    |> render_fn.(children)
  end
end
