defmodule ExTermbox.Renderer.TableTest do
  use ExUnit.Case

  alias ExTermbox.Renderer.{Canvas, Table}

  import ExTermbox.Renderer.View

  describe "render/2" do
    test "returns the table" do
      canvas =
        Table.render(
          Canvas.from_dimensions(15, 5),
          [
            element(:table_row, %{values: ["a", "b", "c"]}, []),
            element(:table_row, %{values: ["d", "e", "f"]}, [])
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
            element(:table_row, %{values: ["very-very-long", "foo"]}, []),
            element(:table_row, %{values: ["short", "bar"]}, [])
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
            element(:table_row, %{values: ["first-column", "this-is-way-too-long"]}, [])
          ]
        )

      assert Canvas.render_to_strings(canvas) === [
               "          ",
               " first-col"
             ]
    end
  end
end
