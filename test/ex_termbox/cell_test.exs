defmodule ExTermbox.CellTest do
  use ExUnit.Case

  alias ExTermbox.{Cell, Constants, Position}

  test "it supports creating a cell struct" do
    cell = %Cell{position: %Position{x: 0, y: 1}, char: ?a, bg: 0x00, fg: 0x01}

    refute nil == cell
  end

  test "it supports creating a cell struct with default bg & fg fields" do
    cell = %Cell{position: %Position{x: 0, y: 0}, char: ?a}

    assert %Cell{
             cell
             | bg: Constants.colors().default,
               fg: Constants.colors().white
           } == cell
  end

  test "it requires the position & char fields" do
    assert_raise(ArgumentError, fn -> struct!(Cell, %{}) end)
  end
end
