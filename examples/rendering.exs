defmodule RenderingDemo do
  @moduledoc """
  This is a kitchen sink example intended to show off most of the
  declarative-style rendering functionality provided by `Ratatouille`.
  """

  alias Ratatouille.{EventManager, Window}

  import Ratatouille.Constants, only: [color: 1, attribute: 1]
  import Ratatouille.Renderer.View

  @refresh_interval 500

  def start do
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    loop()
  end

  def loop do
    state = %{
      current_time: DateTime.utc_now(),
      series_1: for(_ <- 0..50, do: :rand.uniform() * 1000),
      series_2: Enum.shuffle([0, 1, 2, 3, 4, 5, 6])
    }

    with :ok <- Window.update(demo_view(state)) do
      receive do
        {:event, %{ch: ?q}} ->
          :ok = Window.close()
      after
        @refresh_interval ->
          loop()
      end
    else
      err ->
        Window.close()
        IO.write(:stderr, "Render error occurred: " <> inspect(err))
    end
  end

  @style_red [color: color(:red)]

  @style_blue_bold_underlined [
    color: color(:blue),
    attributes: [attribute(:bold), attribute(:underline)]
  ]

  def demo_view(state) do
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
                text(@style_red ++ [content: "Red"])
              end

              label do
                text(
                  @style_blue_bold_underlined ++
                    [content: "Blue, bold underlined"]
                )
              end

              label()
              label(content: "Current Time:")
              label(content: DateTime.to_string(state.current_time))
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
              chart(type: :line, series: state.series_1, height: 6)

              sparkline(series: state.series_2)
            end
          end
        end
      end
    end
  end
end

RenderingDemo.start()
