defmodule Ratatouille.Renderer.RowTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer
  alias Ratatouille.Renderer.{Canvas, Element, Row}

  @three_equal_columns [
    %Element{
      tag: :column,
      attributes: %{size: 4},
      children: %Element{
        tag: :panel,
        attributes: %{title: "Col1"}
      }
    },
    %Element{
      tag: :column,
      attributes: %{size: 4},
      children: %Element{
        tag: :panel,
        attributes: %{title: "Col2"}
      }
    },
    %Element{
      tag: :column,
      attributes: %{size: 4},
      children: %Element{
        tag: :panel,
        attributes: %{title: "Col3"}
      }
    }
  ]

  @two_unequal_columns [
    %Element{
      tag: :column,
      attributes: %{size: 9},
      children: %Element{
        tag: :panel,
        attributes: %{title: "Col1"}
      }
    },
    %Element{
      tag: :column,
      attributes: %{size: 3},
      children: %Element{
        tag: :panel,
        attributes: %{title: "Col2"}
      }
    }
  ]

  @single_full_width_column [
    %Element{
      tag: :column,
      attributes: %{size: 12},
      children: %Element{
        tag: :panel,
        attributes: %{title: "Col1"}
      }
    }
  ]

  @single_partial_width_column [
    %Element{
      tag: :column,
      attributes: %{size: 6},
      children: %Element{
        tag: :panel,
        attributes: %{title: "Col1"}
      }
    }
  ]

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

  def render_canvas(columns, {width, height}) do
    canvas =
      Row.render(
        Canvas.from_dimensions(width, height),
        columns,
        &Renderer.render_tree/2
      )

    Canvas.render_to_strings(canvas)
  end
end
