defmodule Ratatouille.Renderer.BorderTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.{Border, Canvas, Attributes}

  describe "render/2" do
    test "returns a map with the rendered cells" do
      canvas = Border.render(Canvas.from_dimensions(3, 3), nil)

      assert Canvas.render_to_strings(canvas) == [
               "┌─┐",
               "│ │",
               "└─┘"
             ]
    end

    test "supports arbitrary dimensions" do
      canvas = Border.render(Canvas.from_dimensions(10, 3), nil)

      assert Canvas.render_to_strings(canvas) == [
               "┌────────┐",
               "│        │",
               "└────────┘"
             ]
    end

    test "supports color attribute" do
      canvas = Border.render(Canvas.from_dimensions(3, 3), %{color: :blue})

      canvas.cells |> Enum.each(fn {_position, cell} ->
        assert cell.fg == Attributes.to_terminal_color(:blue)
      end)
    end

    test "supports background attribute" do
      canvas = Border.render(Canvas.from_dimensions(3, 3), %{background: :red})

      canvas.cells |> Enum.each(fn {_position, cell} ->
        assert cell.bg == Attributes.to_terminal_color(:red)
      end)
    end
  end
end
