defmodule Ratatouille.Renderer.Element.TreeTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.Canvas
  alias Ratatouille.Renderer.Element.Tree

  import Ratatouille.View

  describe "render/3" do
    test "renders a tree with nested nodes" do
      canvas =
        Tree.render(
          Canvas.from_dimensions(15, 5),
          tree do
            tree_node content: "A" do
              tree_node content: "C" do
                tree_node(content: "F")
              end

              tree_node(content: "D")
            end

            tree_node content: "B" do
              tree_node(content: "E")
            end
          end,
          nil
        )

      assert Canvas.render_to_strings(canvas) === [
               "A        ",
               "├── C    ",
               "│   └── F",
               "└── D    ",
               "B        ",
               "└── E    "
             ]
    end

    test "renders an empty tree" do
      canvas =
        Tree.render(
          Canvas.from_dimensions(15, 5),
          tree(),
          nil
        )

      assert Canvas.render_to_strings(canvas) === [" "]
    end
  end
end
