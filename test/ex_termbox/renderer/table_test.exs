defmodule ExTermbox.Renderer.TableTest do
  use ExUnit.Case

  import ExTermbox.Renderer.Table
  import ExTermbox.Renderer.View

  alias ExTermbox.Renderer.Canvas

  describe "render/2" do
    test "returns the table" do
      canvas =
        Canvas.from_dimensions(15, 5)
        |> render([
          element(:table_row, ["a", "b", "c"]),
          element(:table_row, ["d", "e", "f"])
        ])

      assert Canvas.render_to_strings(canvas) === [
               "          ",
               " a   b   c",
               " d   e   f"
             ]
    end

    test "aligns columns with content of differing lengths" do
      canvas =
        Canvas.from_dimensions(25, 5)
        |> render([
          element(:table_row, ["very-very-long", "foo"]),
          element(:table_row, ["short", "bar"])
        ])

      assert Canvas.render_to_strings(canvas) === [
               "                    ",
               " very-very-long  foo",
               " short           bar"
             ]
    end

    test "only displays columns that fit in the passed box" do
      canvas =
        Canvas.from_dimensions(11, 4)
        |> render([
          element(:table_row, ["first-column", "this-is-way-too-long"])
        ])

      assert Canvas.render_to_strings(canvas) === [
               "          ",
               " first-col"
             ]
    end
  end
end
