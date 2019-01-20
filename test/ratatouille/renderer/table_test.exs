defmodule Ratatouille.Renderer.TableTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.{Canvas, Element, Table}

  @simple [
    %Element{
      tag: :table_row,
      children: [
        %Element{tag: :table_cell, attributes: %{content: "a"}},
        %Element{tag: :table_cell, attributes: %{content: "b"}},
        %Element{tag: :table_cell, attributes: %{content: "c"}}
      ]
    },
    %Element{
      tag: :table_row,
      children: [
        %Element{tag: :table_cell, attributes: %{content: "d"}},
        %Element{tag: :table_cell, attributes: %{content: "e"}},
        %Element{tag: :table_cell, attributes: %{content: "f"}}
      ]
    }
  ]

  @differing_lengths [
    %Element{
      tag: :table_row,
      children: [
        %Element{tag: :table_cell, attributes: %{content: "very-very-long"}},
        %Element{tag: :table_cell, attributes: %{content: "foo"}}
      ]
    },
    %Element{
      tag: :table_row,
      children: [
        %Element{tag: :table_cell, attributes: %{content: "short"}},
        %Element{tag: :table_cell, attributes: %{content: "bar"}}
      ]
    }
  ]

  @truncated [
    %Element{
      tag: :table_row,
      children: [
        %Element{tag: :table_cell, attributes: %{content: "first-column"}},
        %Element{tag: :table_cell, attributes: %{content: "truncated-text"}},
        %Element{tag: :table_cell, attributes: %{content: "not-rendered"}}
      ]
    }
  ]

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

  def render_canvas(table_rows, {width, height}) do
    canvas = Canvas.from_dimensions(width, height)

    canvas
    |> Table.render(table_rows)
    |> Canvas.render_to_strings()
  end
end
