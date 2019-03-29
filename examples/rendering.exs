# This is a kitchen sink example intended to show off most of the
# declarative-style rendering functionality provided by Ratatouille.
#
# Run this example with:
#
#   mix run examples/rendering.exs

defmodule RenderingDemo do
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Subscription

  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  @spacebar key(:space)

  def init(_context) do
    %{
      current_time: DateTime.utc_now(),
      series_1: [],
      series_2: [],
      overlay: true
    }
  end

  def update(model, message) do
    case message do
      {:event, %{key: @spacebar}} ->
        %{model | overlay: !model.overlay}

      :tick ->
        %{
          model
          | current_time: DateTime.utc_now(),
            series_1: for(_ <- 0..50, do: :rand.uniform() * 1000),
            series_2: Enum.shuffle([0, 1, 2, 3, 4, 5, 6])
        }

      _ ->
        model
    end
  end

  def subscribe(_model) do
    Subscription.interval(500, :tick)
  end

  def render(model) do
    top_bar =
      bar do
        label(content: "A top bar for the view")
      end

    bottom_bar =
      bar do
        label(content: "A bottom bar for the view")
      end

    view(top_bar: top_bar, bottom_bar: bottom_bar) do
      panel title: "Rendering Demo", height: :fill do
        row do
          column(size: 4) do
            panel title: "Columns" do
              label(content: "4/12")
            end
          end

          column(size: 3) do
            panel do
              label(content: "3/12")
            end
          end

          column(size: 5) do
            panel do
              label(content: "5/12")
            end
          end
        end

        row do
          column(size: 4) do
            panel title: "Text & Labels" do
              label do
                text(content: "Normal ")
                text(content: "Red", color: :red)
              end

              label do
                text(
                  content: "Blue, bold underlined",
                  color: :blue,
                  attributes: [:bold, :underline]
                )
              end

              label()
              label(content: "Current Time:")
              label(content: DateTime.to_string(model.current_time))
            end
          end

          column(size: 8) do
            panel title: "Tables" do
              table do
                table_row do
                  table_cell(content: "Column 1")
                  table_cell(content: "Column 2")
                  table_cell(content: "Column 3")
                end

                table_row do
                  table_cell(content: "a")
                  table_cell(content: "b")
                  table_cell(content: "c")
                end

                table_row do
                  table_cell(content: "d")
                  table_cell(content: "e")
                  table_cell(content: "f")
                end
              end

              table do
                table_row do
                  table_cell(content: "Column 1")
                  table_cell(content: "Column 2")
                  table_cell(content: "Column 3")
                  table_cell(content: "Column 4")
                end

                table_row do
                  table_cell(content: "g")
                  table_cell(content: "h")
                  table_cell(content: "i")
                  table_cell(content: "j")
                end

                table_row do
                  table_cell(content: "k")
                  table_cell(content: "l")
                  table_cell(content: "m")
                  table_cell(content: "n")
                end
              end
            end
          end
        end

        row do
          column(size: 4) do
            panel title: "Trees" do
              tree do
                tree_node content: "Eukarya" do
                  tree_node content: "Animalia" do
                    tree_node(content: "Chordata") do
                      tree_node(content: "Mammalia")
                      tree_node(content: "Amphibia")
                      tree_node(content: "Reptilia")
                    end

                    tree_node(content: "Arthropoda")
                    tree_node(content: "Annelida")
                  end
                end
              end
            end
          end

          column(size: 8) do
            panel title: "Charts & Sparklines" do
              chart(type: :line, series: model.series_1, height: 6)

              sparkline(series: model.series_2)
            end
          end
        end
      end

      if model.overlay do
        overlay(padding: 15) do
          panel title: "Overlay (toggle with <space>)", height: :fill do
          end
        end
      end
    end
  end
end

Ratatouille.run(RenderingDemo)
