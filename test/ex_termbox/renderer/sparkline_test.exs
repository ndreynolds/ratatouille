defmodule ExTermbox.Renderer.SparklineTest do
  use ExUnit.Case

  import ExTermbox.Renderer.Sparkline

  alias ExTermbox.Renderer.Canvas

  describe "render/2" do
    test "returns the sparkine" do
      canvas = Canvas.from_dimensions(6, 1)
               |> render([1, 40, 18, 5, 7, 50])

      assert Canvas.render_to_strings(canvas) === [
        "▁▇▃▂▂█"
      ]
    end
  end
end
