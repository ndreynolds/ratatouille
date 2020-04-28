defmodule Ratatouille.Renderer.AttributesTest do
  use ExUnit.Case, async: true

  alias Ratatouille.{Constants, Renderer.Attributes}

  describe "to_terminal_color/1" do
    test "with color as atom" do
      assert Attributes.to_terminal_color(:red) == Constants.color(:red)
    end

    test "with color as code" do
      assert Attributes.to_terminal_color(Constants.color(:red)) ==
               Constants.color(:red)
    end

    test "with extended color" do
      assert Attributes.to_terminal_color(17) == 17
    end

    test "when invalid" do
      assert_raise KeyError, fn ->
        Attributes.to_terminal_color(1000)
      end
    end
  end

  describe "to_terminal_attribute/1" do
    test "with color as atom" do
      assert Attributes.to_terminal_attribute(:bold) ==
               Constants.attribute(:bold)
    end

    test "with color as code" do
      assert Attributes.to_terminal_attribute(Constants.attribute(:bold)) ==
               Constants.attribute(:bold)
    end

    test "when invalid" do
      assert_raise KeyError, fn ->
        Attributes.to_terminal_attribute(1000)
      end
    end
  end
end
