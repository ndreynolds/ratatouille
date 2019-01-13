defmodule Ratatouille.Renderer.SparklineTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.{Canvas, Sparkline}

  describe "render/2" do
    test "returns the sparkine" do
      canvas =
        Sparkline.render(
          Canvas.from_dimensions(6, 1),
          %{series: [1, 40, 18, 5, 7, 50]}
        )

      assert Canvas.render_to_strings(canvas) === ["▁▇▃▂▂█"]
    end
  end
end
