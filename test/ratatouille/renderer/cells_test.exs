defmodule Ratatouille.Renderer.CellsTest do
  use ExUnit.Case, async: true
  use Bitwise

  alias Ratatouille.{Constants, Renderer.Cells}

  describe "foreground/1" do
    test "with color as atom" do
      assert Cells.foreground(%{color: :red}) == Constants.color(:red)
    end

    test "with color as code" do
      assert Cells.foreground(%{color: Constants.color(:red)}) ==
               Constants.color(:red)
    end

    test "with attributes" do
      assert Cells.foreground(%{color: :red, attributes: [:bold, :underline]}) ==
               (Constants.color(:red) ||| Constants.attribute(:bold) |||
                  Constants.attribute(:underline))
    end

    test "when unspecified" do
      assert Cells.foreground(%{}) == Constants.color(:default)
    end
  end

  describe "background/1" do
    test "with background as atom" do
      assert Cells.background(%{background: :blue}) == Constants.color(:blue)
    end

    test "with background as code" do
      assert Cells.background(%{background: Constants.color(:blue)}) ==
               Constants.color(:blue)
    end

    test "when unspecified" do
      assert Cells.background(%{}) == Constants.color(:default)
    end
  end
end
