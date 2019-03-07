defmodule Ratatouille.Renderer.Element.TableTest do
  use ExUnit.Case, async: true

  alias ExTermbox.{Cell, Position}

  alias Ratatouille.Renderer.Canvas
  alias Ratatouille.Renderer.Element.Table

  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1]

  @red color(:red)
  @blue color(:blue)

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

  @styled (table do
             table_row(color: @red) do
               table_cell(content: "a")
               table_cell(content: "b", color: @blue)
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

    test "styling and styling inheritance" do
      assert %Canvas{cells: cells} =
               Table.render(
                 Canvas.from_dimensions(5, 1),
                 @styled,
                 nil
               )

      assert %{
               %Position{x: 0, y: 0} => %Cell{
                 ch: ?a,
                 fg: @red,
                 position: %Position{x: 0, y: 0}
               },
               %Position{x: 3, y: 0} => %Cell{
                 ch: ?b,
                 fg: @blue,
                 position: %Position{x: 3, y: 0}
               }
             } = cells
    end
  end

  def render_canvas(table, {width, height}) do
    canvas = Canvas.from_dimensions(width, height)

    canvas
    |> Table.render(table, nil)
    |> Canvas.render_to_strings()
  end
end
