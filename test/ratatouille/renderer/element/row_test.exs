defmodule Ratatouille.Renderer.Element.RowTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer
  alias Ratatouille.Renderer.Canvas
  alias Ratatouille.Renderer.Element.Row

  import Ratatouille.View

  @three_equal_columns (row do
                          column size: 4 do
                            panel(title: "Col1")
                          end

                          column size: 4 do
                            panel(title: "Col2")
                          end

                          column size: 4 do
                            panel(title: "Col3")
                          end
                        end)

  @two_unequal_columns (row do
                          column size: 9 do
                            panel(title: "Col1")
                          end

                          column size: 3 do
                            panel(title: "Col2")
                          end
                        end)

  @single_full_width_column (row do
                               column size: 12 do
                                 panel(title: "Col1")
                               end
                             end)

  @single_partial_width_column (row do
                                  column size: 6 do
                                    panel(title: "Col1")
                                  end
                                end)

  describe "render/3" do
    test "renders columns evenly using full width" do
      assert [
               "┌─Col1───┐┌─Col2───┐┌─Col3───┐" = line,
               "│        ││        ││        │",
               "└────────┘└────────┘└────────┘"
             ] = render_canvas(@three_equal_columns, {30, 3})

      assert String.length(line) == 30
    end

    test "adds margin between columns if extra width available" do
      assert [
               "┌─Col1───┐ ┌─Col2───┐ ┌─Col3───┐" = line,
               "│        │ │        │ │        │",
               "└────────┘ └────────┘ └────────┘"
             ] = render_canvas(@three_equal_columns, {32, 3})

      assert String.length(line) == 32
    end

    test "adds no margin if unable to apply evenly" do
      assert [
               "┌─Col1───┐┌─Col2───┐┌─Col3───┐" = line,
               "│        ││        ││        │",
               "└────────┘└────────┘└────────┘"
             ] = render_canvas(@three_equal_columns, {31, 3})

      assert String.length(line) == 30
    end

    test "supports mixed column size layouts" do
      assert [
               "┌─Col1───────────────┐ ┌─Col2┐" = line,
               "│                    │ │     │",
               "└────────────────────┘ └─────┘"
             ] = render_canvas(@two_unequal_columns, {30, 3})

      assert String.length(line) == 30
    end

    test "supports single column layout (full width)" do
      assert [
               "┌─Col1───────────────────────┐" = line,
               "│                            │",
               "└────────────────────────────┘"
             ] = render_canvas(@single_full_width_column, {30, 3})

      assert String.length(line) == 30
    end

    test "supports single column layout (partial width)" do
      assert [
               "┌─Col1────────┐" = line,
               "│             │",
               "└─────────────┘"
             ] = render_canvas(@single_partial_width_column, {30, 3})

      assert String.length(line) == 15
    end
  end

  def render_canvas(row, {width, height}) do
    canvas = Canvas.from_dimensions(width, height)

    canvas
    |> Row.render(row, &Renderer.render_tree/2)
    |> Canvas.render_to_strings()
  end
end
