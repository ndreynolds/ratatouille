defmodule Ratatouille.Renderer.UtilsTest do
  use ExUnit.Case, async: true

  import Ratatouille.Renderer.Utils

  describe "atoi/1" do
    assert atoi("a") == ?a
    assert atoi("b") == ?b
  end
end
