defmodule ExTermbox.Renderer.RowTest do
  use ExUnit.Case

  alias ExTermbox.{Renderer, Renderer.Canvas, Renderer.Element}
  import ExTermbox.Renderer.Row

  describe "render/3" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(24, 1)

      # TODO: Add additional lines of content
      assert ["Col1  Col2"] =
               render(
                 empty_canvas,
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
               |> Canvas.render_to_strings()
    end
  end
end
