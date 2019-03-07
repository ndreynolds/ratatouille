defmodule Ratatouille.Renderer.Element.PanelTest do
  use ExUnit.Case, async: true

  alias Ratatouille.Renderer
  alias Ratatouille.Renderer.{Canvas, Element.Panel}

  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1]

  @panel_with_title (panel title: "The Title" do
                       label(content: "Body content")
                     end)

  @panel_with_highlighted_title (panel title: {"Highlighted Title", [color: color(:red)] } do
                       label(content: "Body contentt")
    end)

  @panel_with_explicit_height panel(height: 5)

  @panel_with_filled_height panel(height: :fill)

  @multi_panel_view (view do
                       row do
                         column(size: 12) do
                           panel do
                             label(content: "A")
                           end

                           panel do
                             label(content: "B")
                           end

                           panel do
                             table do
                               for ch <- ?C..?L do
                                 table_row do
                                   table_cell(content: <<ch::utf8>>)
                                 end
                               end
                             end
                           end
                         end
                       end
                     end)

  describe "render/3" do
    test "renders border and title" do
      canvas =
        Panel.render(
          Canvas.from_dimensions(16, 4),
          @panel_with_title,
          &Renderer.render_tree/2
        )

      assert Canvas.render_to_strings(canvas) ===
               [
                 "┌─The Title────┐",
                 "│              │",
                 "│ Body content │",
                 "└──────────────┘"
               ]
    end

    test "renders border and highlighted title" do
      canvas =
        Panel.render(
          Canvas.from_dimensions(16, 4),
          @panel_with_highlighted_title,
          &Renderer.render_tree/2
        )

      assert Canvas.render_to_strings(canvas) ===
               [
                 "┌─Highlighted Ti",
                 "│              │",
                 "│ Body content │",
                 "└──────────────┘"
               ]
    end

    test "renders with explicit height" do
      canvas =
        Panel.render(
          Canvas.from_dimensions(16, 10),
          @panel_with_explicit_height,
          &Renderer.render_tree/2
        )

      assert Canvas.render_to_strings(canvas) ===
               [
                 "┌──────────────┐",
                 "│              │",
                 "│              │",
                 "│              │",
                 "└──────────────┘"
               ]
    end

    test "renders with filled height" do
      canvas =
        Panel.render(
          Canvas.from_dimensions(16, 10),
          @panel_with_filled_height,
          &Renderer.render_tree/2
        )

      assert Canvas.render_to_strings(canvas) ===
               [
                 "┌──────────────┐",
                 "│              │",
                 "│              │",
                 "│              │",
                 "│              │",
                 "│              │",
                 "│              │",
                 "│              │",
                 "│              │",
                 "└──────────────┘"
               ]
    end
  end

  describe "complex multi-panel layouts" do
    test "correctly applies padding, margins and offset" do
      assert {:ok, canvas} =
               Renderer.render(
                 Canvas.from_dimensions(8, 30),
                 @multi_panel_view
               )

      assert Canvas.render_to_strings(canvas) ===
               [
                 "┌──────┐",
                 "│      │",
                 "│ A    │",
                 "└──────┘",
                 "┌──────┐",
                 "│      │",
                 "│ B    │",
                 "└──────┘",
                 "┌──────┐",
                 "│      │",
                 "│ C    │",
                 "│ D    │",
                 "│ E    │",
                 "│ F    │",
                 "│ G    │",
                 "│ H    │",
                 "│ I    │",
                 "│ J    │",
                 "│ K    │",
                 "│ L    │",
                 "│      │",
                 "└──────┘"
               ]
    end
  end
end
