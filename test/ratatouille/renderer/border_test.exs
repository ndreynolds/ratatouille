defmodule Ratatouille.Renderer.BorderTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.{Border, Canvas}

  describe "render/2" do
    test "returns a map with the rendered cells" do
      canvas = Border.render(Canvas.from_dimensions(3, 3))

      assert Canvas.render_to_strings(canvas) == [
               "┌─┐",
               "│ │",
               "└─┘"
             ]
    end

    test "supports arbitrary dimensions" do
      canvas = Border.render(Canvas.from_dimensions(10, 3))

      assert Canvas.render_to_strings(canvas) == [
               "┌────────┐",
               "│        │",
               "└────────┘"
             ]
    end
  end
end
