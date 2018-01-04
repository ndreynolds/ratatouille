defmodule ExTermboxTest do
  use ExUnit.Case
  doctest ExTermbox

  test "greets the world" do
    assert ExTermbox.hello() == :world
  end
end
