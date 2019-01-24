defmodule Ratatouille.RendererTest do
  use ExUnit.Case, async: true

  import Ratatouille.View

  alias Ratatouille.Renderer

  describe "validate_tree/1" do
    test "returns :ok for a valid tree" do
      valid_tree =
        view do
          row do
            column(size: 1) do
              label()
            end
          end
        end

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
      assert {:error,
              "Invalid view hierarchy: 'column' cannot be a child of 'view'"} =
               Renderer.validate_tree(
                 view do
                   column(size: 1)
                 end
               )

      assert {:error,
              "Invalid view hierarchy: 'panel' cannot be a child of 'row'"} =
               Renderer.validate_tree(
                 view do
                   row do
                     panel()
                   end
                 end
               )

      assert {:error,
              "Invalid view hierarchy: 'text' cannot be a child of 'column'"} =
               Renderer.validate_tree(
                 view do
                   row do
                     column(size: 1) do
                       text()
                     end
                   end
                 end
               )
    end

    test "validates attributes" do
      assert {:error,
              "Invalid attributes: 'panel' does not accept attributes [:invalid]"} =
               Renderer.validate_tree(
                 view do
                   panel(invalid: 42)
                 end
               )

      assert {:error,
              "Invalid attributes: 'column' is missing required attributes [:size]"} =
               Renderer.validate_tree(
                 view do
                   row do
                     column()
                   end
                 end
               )
    end
  end
end
