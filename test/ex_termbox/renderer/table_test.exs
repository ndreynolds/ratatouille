defmodule ExTermbox.Renderer.TableTest do
  use ExUnit.Case

  alias ExTermbox.Renderer.{Canvas, Table, View}

  describe "render/2" do
    test "returns the table" do
      canvas =
        Table.render(
          Canvas.from_dimensions(15, 5),
          [
            View.element(:table_row, ["a", "b", "c"]),
            View.element(:table_row, ["d", "e", "f"])
          ]
        )

      assert Canvas.render_to_strings(canvas) === [
               "          ",
               " a   b   c",
               " d   e   f"
             ]
    end

    test "aligns columns with content of differing lengths" do
      canvas =
        Table.render(
          Canvas.from_dimensions(25, 5),
          [
            View.element(:table_row, ["very-very-long", "foo"]),
            View.element(:table_row, ["short", "bar"])
          ]
        )

      assert Canvas.render_to_strings(canvas) === [
               "                    ",
               " very-very-long  foo",
               " short           bar"
             ]
    end

    test "only displays columns that fit in the passed box" do
      canvas =
        Table.render(
          Canvas.from_dimensions(11, 4),
          [
            View.element(:table_row, ["first-column", "this-is-way-too-long"])
          ]
        )

      assert Canvas.render_to_strings(canvas) === [
               "          ",
               " first-col"
             ]
    end
  end
end
