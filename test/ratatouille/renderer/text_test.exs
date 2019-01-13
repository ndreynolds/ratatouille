defmodule Ratatouille.Renderer.TextTest do
  use ExUnit.Case, async: true

  import Ratatouille.Renderer.Text

  alias ExTermbox.{Cell, Position}
  alias Ratatouille.Renderer.Canvas

  describe "render/3" do
    test "returns a map with the rendered cells" do
      empty_canvas = Canvas.from_dimensions(10, 10)

      assert %Canvas{
               cells: %{
                 %Position{x: 0, y: 0} => %Cell{ch: ?H},
                 %Position{x: 1, y: 0} => %Cell{ch: ?e},
                 %Position{x: 2, y: 0} => %Cell{ch: ?l},
                 %Position{x: 3, y: 0} => %Cell{ch: ?l},
                 %Position{x: 4, y: 0} => %Cell{ch: ?o},
                 %Position{x: 5, y: 0} => %Cell{ch: ?!}
               }
             } = render(empty_canvas, %Position{x: 0, y: 0}, "Hello!")
    end
  end
end
