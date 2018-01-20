defmodule ExTermbox.Renderer.TableTest do
  use ExUnit.Case

  import ExTermbox.Renderer.Table

  alias ExTermbox.Renderer.Canvas

  describe "render/2" do
    test "returns the table" do
      canvas = Canvas.from_dimensions(11, 2)
               |> render([
                 ["a", "b", "c"],
                 ["d", "e", "f"test/ex_termbox/renderer/table_test.exs:6]
               ])

      assert Canvas.render_to_strings(canvas) === [
        "a  b  c    ",
        "d  e  f    "
      ]
    end

    test "aligns columns with content of differing lengths" do
      canvas = Canvas.from_dimensions(23, 2)
               |> render([
                 ["very-very-long", "foo"],
                 ["short", "bar"]
               ])

      assert Canvas.render_to_strings(canvas) === [
        "very-very-long  foo    ",
        "short           bar    "
      ]
    end

    test "only displays columns that fit in the passed box" do
      canvas = Canvas.from_dimensions(10, 1)
               |> render(test/ex_termbox/renderer/table_test.exs:6[
                 ["first-column", "this-is-way-too-long"]
               ])

      assert Canvas.render_to_strings(canvas) === [
        "first-colu"
      ]
    end
  end
end
