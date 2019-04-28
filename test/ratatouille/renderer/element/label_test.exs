defmodule Ratatouille.Renderer.Element.LabelTest do
  use ExUnit.Case, async: true

  alias ExTermbox.{Cell, Position}

  alias Ratatouille.Renderer.Canvas
  alias Ratatouille.Renderer.Element.Label

  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1]

  @red color(:red)
  @blue color(:blue)

  describe "render/3" do
    test "renders simple content" do
      assert render_to_strings(
               label(content: "Hello, World!"),
               {15, 1}
             ) === ["Hello, World!"]
    end

    test "renders multi-line content" do
      assert render_to_strings(
               label(content: "Hello\nWorld!"),
               {15, 1}
             ) === [
               "Hello ",
               "World!"
             ]
    end

    test "supports line wrapping" do
      assert render_to_strings(
               label(content: "Hello, World!", wrap: true),
               {8, 2}
             ) === [
               "Hello, ",
               "World! "
             ]
    end

    test "renders nested text nodes" do
      assert render_to_strings(
               label do
                 text(content: "A")
                 text(content: "B")
                 text(content: "C")
               end,
               {15, 1}
             ) === ["ABC"]
    end

    test "styling attributes on label" do
      %Canvas{cells: cells} =
        render_canvas(
          label(content: "Hello", color: :blue),
          {15, 1}
        )

      assert %{
               %Position{x: 0, y: 0} => %Cell{
                 ch: ?H,
                 fg: @blue,
                 position: %Position{x: 0, y: 0}
               },
               %Position{x: 1, y: 0} => %Cell{
                 ch: ?e,
                 fg: @blue,
                 position: %Position{x: 1, y: 0}
               }
             } = cells
    end

    test "child nodes inherit styling attributes" do
      %Canvas{cells: cells} =
        render_canvas(
          label(color: :red) do
            text(content: "A")
            text(content: "B")
            text(content: "C", color: :blue)
          end,
          {15, 1}
        )

      assert %{
               %Position{x: 0, y: 0} => %Cell{
                 ch: ?A,
                 fg: @red,
                 position: %Position{x: 0, y: 0}
               },
               %Position{x: 1, y: 0} => %Cell{
                 ch: ?B,
                 fg: @red,
                 position: %Position{x: 1, y: 0}
               },
               %Position{x: 2, y: 0} => %Cell{
                 ch: ?C,
                 fg: @blue,
                 position: %Position{x: 2, y: 0}
               }
             } = cells
    end
  end

  def render_canvas(label, {width, height}) do
    canvas = Canvas.from_dimensions(width, height)

    canvas
    |> Label.render(label, nil)
  end

  def render_to_strings(label, dims) do
    label
    |> render_canvas(dims)
    |> Canvas.render_to_strings()
  end
end
