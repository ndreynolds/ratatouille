defmodule Ratatouille.Renderer.TableTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.{Canvas, Table}

  import Ratatouille.Renderer.View

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

      assert [
               "a    b    c    " = line,
               "d    e    f    "
             ] = Canvas.render_to_strings(canvas)

      assert String.length(line) == 15
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

      assert [
               "very-very-long    foo    " = line,
               "short             bar    "
             ] = Canvas.render_to_strings(canvas)

      assert String.length(line) == 25
    end

    test "only displays columns that fit in the passed box" do
      canvas =
        Table.render(
          Canvas.from_dimensions(20, 4),
          [
            element(
              :table_row,
              %{values: ["first-column", "truncated-text", "not-rendered"]},
              []
            )
          ]
        )

      assert Canvas.render_to_strings(canvas) === [
               "first-column  trunca"
             ]
    end
  end
end
