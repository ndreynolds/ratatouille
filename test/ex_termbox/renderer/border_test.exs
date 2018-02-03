defmodule ExTermbox.Renderer.BorderTest do
  use ExUnit.Case

  import ExTermbox.Renderer.Border

  alias ExTermbox.Renderer.Canvas

  describe "render/2" do
    test "returns a map with the rendered cells" do
      canvas =
        Canvas.from_dimensions(3, 3)
        |> render()

      assert Canvas.render_to_strings(canvas) == [
               "┌─┐",
               "│ │",
               "└─┘"
             ]
    end

    test "supports arbitrary dimensions" do
      canvas =
        Canvas.from_dimensions(10, 3)
        |> render()

      assert Canvas.render_to_strings(canvas) == [
               "┌────────┐",
               "│        │",
               "└────────┘"
             ]
    end
  end
end
