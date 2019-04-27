defmodule Ratatouille.Renderer.Element.ViewportTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer.Canvas
  alias Ratatouille.Renderer.Element.Viewport

  import Ratatouille.View

  describe "render/3" do
    test "renders child content without offset specified" do
      assert render_canvas(
               viewport do
                 label(content: "Foo")
               end
             ) === ["Foo"]
    end

    test "renders child content offset by x value" do
      assert render_canvas(
               viewport offset_x: 0 do
                 label(content: "Foo")
               end
             ) === ["Foo"]

      assert render_canvas(
               viewport offset_x: 1 do
                 label(content: "Foo")
               end
             ) === ["oo"]

      assert render_canvas(
               viewport offset_x: 2 do
                 label(content: "Foo")
               end
             ) === ["o"]

      assert render_canvas(
               viewport offset_x: 3 do
                 label(content: "Foo")
               end
             ) === [" "]
    end

    test "renders child content offset by y value" do
      assert render_canvas(
               viewport offset_y: 0 do
                 label(content: "Foo")
                 label(content: "Bar")
                 label(content: "Baz")
               end
             ) === ["Foo", "Bar", "Baz"]

      assert render_canvas(
               viewport offset_y: 1 do
                 label(content: "Foo")
                 label(content: "Bar")
                 label(content: "Baz")
               end
             ) === ["Bar", "Baz"]

      assert render_canvas(
               viewport offset_y: 2 do
                 label(content: "Foo")
                 label(content: "Bar")
                 label(content: "Baz")
               end
             ) === ["Baz"]

      assert render_canvas(
               viewport offset_y: 3 do
                 label(content: "Foo")
                 label(content: "Bar")
                 label(content: "Baz")
               end
             ) === [" "]
    end

    test "renders child content offset by x and y values" do
      assert render_canvas(
               viewport offset_x: 2, offset_y: 1 do
                 label(content: "Foo")
                 label(content: "Bar")
               end
             ) === ["r"]
    end

    test "supports negative offsets" do
      assert render_canvas(
               viewport offset_x: -2, offset_y: -1 do
                 label(content: "Foo")
                 label(content: "Bar")
               end
             ) == ["     ", "  Foo", "  Bar"]
    end
  end

  def render_canvas(element) do
    canvas = Canvas.from_dimensions(6, 2)

    canvas
    |> Viewport.render(element, &Ratatouille.Renderer.render_tree/2)
    |> Canvas.render_to_strings()
  end
end
