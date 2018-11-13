defmodule ExTermbox.Renderer.TextTest do
  use ExUnit.Case, async: true

  import ExTermbox.Renderer.Text

  alias ExTermbox.{Cell, Position}
  alias ExTermbox.Renderer.Canvas

  describe "render/3" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
               cells: %{
                 %Position{x: 0, y: 0} => %Cell{char: ?H},
                 %Position{x: 1, y: 0} => %Cell{char: ?e},
                 %Position{x: 2, y: 0} => %Cell{char: ?l},
                 %Position{x: 3, y: 0} => %Cell{char: ?l},
                 %Position{x: 4, y: 0} => %Cell{char: ?o},
                 %Position{x: 5, y: 0} => %Cell{char: ?!}
               }
             } = render(empty_canvas, %Position{x: 0, y: 0}, "Hello!")
    end
  end
end
