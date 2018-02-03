defmodule ExTermbox.Renderer.LineTest do
  use ExUnit.Case

  import ExTermbox.Renderer.Line

  alias ExTermbox.{Cell, Position}
  alias ExTermbox.Renderer.Canvas

  describe "render_vertical/4" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
               cells: %{
                 %Position{x: 0, y: 0} => %Cell{char: ?|},
                 %Position{x: 0, y: 1} => %Cell{char: ?|},
                 %Position{x: 0, y: 2} => %Cell{char: ?|}
               }
             } = render_vertical(empty_canvas, %Position{x: 0, y: 0}, "|", 3)
    end
  end

  describe "render_horizontal/4" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
               cells: %{
                 %Position{x: 0, y: 0} => %Cell{char: ?-},
                 %Position{x: 1, y: 0} => %Cell{char: ?-},
                 %Position{x: 2, y: 0} => %Cell{char: ?-}
               }
             } =
               render_horizontal(
                 empty_canvas,
                 %Position{x: 0, y: 0},
                 "-",
                 3
               )
    end
  end
end
