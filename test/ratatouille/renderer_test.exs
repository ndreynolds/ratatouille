defmodule Ratatouille.RendererTest do
  use ExUnit.Case, async: true

  import Ratatouille.Renderer.View, only: [element: 2]

  alias Ratatouille.Renderer

  describe "validate_tree/1" do
    test "returns :ok for a valid tree" do
      valid_tree =
        element(:view, [
          element(:row, [
            element(:column, [
              element(:label, [])
            ])
          ])
        ])

      assert Renderer.validate_tree(valid_tree) == :ok
    end

    test "validates root element is a `view`" do
      assert {:error,
              "Invalid view hierarchy: Root element must have tag 'view', but found 'panel'"} =
               Renderer.validate_tree(element(:panel, []))

      assert {:error,
              "Invalid view hierarchy: Root element must have tag 'view', but found 'text'"} =
               Renderer.validate_tree(element(:text, []))
    end

    test "validates relationships" do
      assert {:error, "Invalid view hierarchy: 'column' cannot be a child of 'view'"} =
               Renderer.validate_tree(
                 element(:view, [
                   element(:column, [])
                 ])
               )

      assert {:error, "Invalid view hierarchy: 'panel' cannot be a child of 'row'"} =
               Renderer.validate_tree(
                 element(:view, [
                   element(:row, [
                     element(:panel, [])
                   ])
                 ])
               )

      assert {:error, "Invalid view hierarchy: 'text' cannot be a child of 'column'"} =
               Renderer.validate_tree(
                 element(:view, [
                   element(:row, [
                     element(:column, [
                       element(:text, [])
                     ])
                   ])
                 ])
               )
    end
  end
end
