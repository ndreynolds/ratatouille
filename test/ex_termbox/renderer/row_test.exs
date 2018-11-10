defmodule ExTermbox.Renderer.RowTest do
  use ExUnit.Case

  alias ExTermbox.Renderer
  alias ExTermbox.Renderer.{Canvas, Element, Row}

  describe "render/3" do
    test "returns a map with the rendered cells" do
      # TODO: Add additional lines of content

      canvas =
        Row.render(
          Canvas.from_dimensions(24, 1),
          [
            %Element{
              tag: :column,
              attributes: %{size: 6},
              children: %Element{tag: :text, children: ["Col1"]}
            },
            %Element{
              tag: :column,
              attributes: %{size: 6},
              children: %Element{tag: :text, children: ["Col2"]}
            }
          ],
          &Renderer.render_tree/2
        )

      assert ["Col1       Col2"] = Canvas.render_to_strings(canvas)
    end
  end
end
