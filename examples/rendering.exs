defmodule RenderingDemo do
  @moduledoc """
  This is a kitchen sink example intended to show off most of the
  declarative-style rendering functionality provided by `ExTermbox`.
  """

  alias ExTermbox.{EventManager, Event, Window}

  import ExTermbox.Renderer.View
  import ExTermbox.Constants, only: [color: 1, attribute: 1]

  @refresh_interval 500

  def run do
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
        {:event, %Event{ch: ?q}} ->
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
                text(@style_red ++ [content: "Red text"])
                text(content: " ")
                text(@style_blue_bold_underlined ++ [content: "Blue, bold underlined text"])
              end

              label(content: "Current Time: " <> DateTime.to_string(state.current_time))
            end
          end

          column(size: 8) do
            panel title: "Tables" do
              table do
                table_row(values: ["Column 1", "Column 2", "Column 3"])
                table_row(values: ["a", "b", "c"])
                table_row(values: ["d", "e", "f"])
              end

              table do
                table_row(values: ["Column 1", "Column 2", "Column 3", "Column 4"])
                table_row(values: ["g", "h", "i", "j"])
                table_row(values: ["k", "l", "m", "n"])
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

RenderingDemo.run()
