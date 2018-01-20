defmodule ExTermbox.Renderer.UtilsTest do
  use ExUnit.Case

  import ExTermbox.Renderer.Utils

  alias ExTermbox.{Cell, Position}
  alias ExTermbox.Renderer.Canvas

  describe "render_text/3" do
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
      } = render_text(empty_canvas, %Position{x: 0, y: 0}, "Hello!")
    end
  end

  describe "render_vertical_line/4" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
        cells: %{
          %Position{x: 0, y: 0} => %Cell{char: ?|},
          %Position{x: 0, y: 1} => %Cell{char: ?|},
          %Position{x: 0, y: 2} => %Cell{char: ?|},
        }
      } = render_vertical_line(empty_canvas, %Position{x: 0, y: 0}, "|", 3)
    end
  end

  describe "render_horizontal_line/4" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
        cells: %{
          %Position{x: 0, y: 0} => %Cell{char: ?-},
          %Position{x: 1, y: 0} => %Cell{char: ?-},
          %Position{x: 2, y: 0} => %Cell{char: ?-},
        }
      } = render_horizontal_line(empty_canvas, %Position{x: 0, y: 0}, "-", 3)
    end
  end

  describe "render_border/2" do
    test "returns a map with the rendered cells" do
      canvas = Canvas.from_dimensions(3, 3)
               |> render_border()

      assert Canvas.render_to_strings(canvas) == [
        "┌─┐",
        "│ │",
        "└─┘"
      ]
    end

    test "supports arbitrary dimensions" do
      canvas = Canvas.from_dimensions(10, 3)
               |> render_border()

      assert Canvas.render_to_strings(canvas) == [
        "┌────────┐",
        "│        │",
        "└────────┘"
      ]
    end
  end
end
