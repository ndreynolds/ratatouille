defmodule Ratatouille.Renderer.Element.LabelTest do
  use ExUnit.Case, async: true

  alias ExTermbox.{Cell, Position}

  alias Ratatouille.Renderer.Canvas
  alias Ratatouille.Renderer.Element.Label

  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1]

  @red color(:red)
  @blue color(:blue)

  @simple label(content: "Hello, World!", color: @blue)

  @nested (label(color: @red) do
             text(content: "A")
             text(content: "B")
             text(content: "C", color: @blue)
           end)

  describe "render/3" do
    test "renders simple content" do
      canvas =
        Label.render(
          Canvas.from_dimensions(15, 1),
          @simple,
          nil
        )

      assert Canvas.render_to_strings(canvas) === ["Hello, World!"]
    end

    test "renders nested text nodes" do
      canvas =
        Label.render(
          Canvas.from_dimensions(15, 1),
          @nested,
          nil
        )

      assert Canvas.render_to_strings(canvas) === ["ABC"]
    end

    test "styling attributes on label" do
      %Canvas{cells: cells} =
        Label.render(
          Canvas.from_dimensions(15, 1),
          @simple,
          nil
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
        Label.render(
          Canvas.from_dimensions(15, 1),
          @nested,
          nil
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
end
