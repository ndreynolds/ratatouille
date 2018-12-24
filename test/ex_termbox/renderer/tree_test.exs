defmodule ExTermbox.Renderer.TreeTest do
  use ExUnit.Case, async: true

  alias ExTermbox.Renderer.{Canvas, Tree}

  import ExTermbox.Renderer.View

  describe "render/2" do
    test "renders a tree with nested nodes" do
      canvas =
        Tree.render(
          Canvas.from_dimensions(15, 5),
          [
            element(:tree_node, %{content: "A"}, [
              element(:tree_node, %{content: "C"}, [
                element(:tree_node, %{content: "F"}, [])
              ]),
              element(:tree_node, %{content: "D"}, [])
            ]),
            element(:tree_node, %{content: "B"}, [
              element(:tree_node, %{content: "E"}, [])
            ])
          ]
        )

      assert Canvas.render_to_strings(canvas) === [
               "          ",
               " A        ",
               " ├── C    ",
               " │   └── F",
               " └── D    ",
               " B        ",
               " └── E    "
             ]
    end

    test "renders an empty tree" do
      canvas =
        Tree.render(
          Canvas.from_dimensions(15, 5),
          []
        )

      assert Canvas.render_to_strings(canvas) === [" "]
    end
  end
end
