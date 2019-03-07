defmodule Ratatouille.Renderer.Element.TableTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.Canvas
  alias Ratatouille.Renderer.Element.Table

  import Ratatouille.View

  @simple (table do
             table_row do
               table_cell(content: "a")
               table_cell(content: "b")
               table_cell(content: "c")
             end

             table_row do
               table_cell(content: "d")
               table_cell(content: "e")
               table_cell(content: "f")
             end
           end)

  @differing_lengths (table do
                        table_row do
                          table_cell(content: "very-very-long")
                          table_cell(content: "foo")
                        end

                        table_row do
                          table_cell(content: "short")
                          table_cell(content: "bar")
                        end
                      end)

  @truncated (table do
                table_row do
                  table_cell(content: "first-column")
                  table_cell(content: "truncated-text")
                  table_cell(content: "not-rendered")
                end
              end)

  describe "render/2" do
    test "returns the table" do
      assert [
               "a    b    c    " = line,
               "d    e    f    "
             ] = render_canvas(@simple, {15, 5})

      assert String.length(line) == 15
    end

    test "aligns columns with content of differing lengths" do
      assert [
               "very-very-long    foo    " = line,
               "short             bar    "
             ] = render_canvas(@differing_lengths, {25, 5})

      assert String.length(line) == 25
    end

    test "only displays columns that fit in the passed box" do
      assert [
               "first-column  trunca" = line
             ] = render_canvas(@truncated, {20, 4})

      assert String.length(line) == 20
    end
  end

  def render_canvas(table, {width, height}) do
    canvas = Canvas.from_dimensions(width, height)

    canvas
    |> Table.render(table, nil)
    |> Canvas.render_to_strings()
  end
end
