defmodule Ratatouille.Renderer.LineTest do
  use ExUnit.Case, async: true

  alias ExTermbox.{Cell, Position}
  alias Ratatouille.Renderer.{Canvas, Line}

  describe "render_vertical/4" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
               cells: %{
                 %Position{x: 0, y: 0} => %Cell{ch: ?|},
                 %Position{x: 0, y: 1} => %Cell{ch: ?|},
                 %Position{x: 0, y: 2} => %Cell{ch: ?|}
               }
             } =
               Line.render_vertical(empty_canvas, %Position{x: 0, y: 0}, "|", 3, nil)
    end
  end

  describe "render_horizontal/4" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
               cells: %{
                 %Position{x: 0, y: 0} => %Cell{ch: ?-},
                 %Position{x: 1, y: 0} => %Cell{ch: ?-},
                 %Position{x: 2, y: 0} => %Cell{ch: ?-}
               }
             } =
               Line.render_horizontal(
                 empty_canvas,
                 %Position{x: 0, y: 0},
                 "-",
                 3,
                 nil
               )
    end
  end
end
