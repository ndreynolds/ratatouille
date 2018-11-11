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
    with :ok <- Window.update(demo_view()) do
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

  def demo_view do
    top_bar =
      bar do
        label("A top bar for the view")
      end

    bottom_bar =
      bar do
        label("A bottom bar for the view")
      end

    view(top_bar: top_bar, bottom_bar: bottom_bar) do
      panel title: "Rendering Demo", height: :fill do
        row do
          column(size: 6) do
            panel title: "Column 1 Row 1" do
              label do
                text(@style_red, "Red text")
                text(" ")
                text(@style_blue_bold_underlined, "Blue, bold underlined text")
              end

              table do
                table_row([
                  "Current Time:",
                  DateTime.utc_now() |> DateTime.to_string()
                ])
              end

              table do
                table_row(["Column 1", "Column 2", "Column 3"])
                table_row(["a", "b", "c"])
                table_row(["d", "e", "f"])
              end

              table do
                table_row(["Random Number:", inspect(:rand.uniform())])

                table_row([
                  "Hello:",
                  String.duplicate("World", Enum.random(1..3))
                ])
              end
            end
          end

          column(size: 6) do
            panel title: "Column 2 Row 1" do
              sparkline(Enum.shuffle([0, 1, 2, 3, 4, 5, 6]))

              table do
                table_row([
                  "Current Time:",
                  DateTime.utc_now() |> DateTime.to_string()
                ])
              end

              table do
                table_row(["Column 1", "Column 2", "Column 3"])
                table_row(["a", "b", "c"])
                table_row(["d", "e", "f"])
              end

              table do
                table_row(["Random Number:", inspect(:rand.uniform())])

                table_row([
                  "Hello:",
                  String.duplicate("World", Enum.random(1..3))
                ])
              end
            end
          end
        end

        row do
          column(size: 3) do
            panel title: "Column 1 Row 2" do
              table do
                table_row([
                  "Current Time:",
                  DateTime.utc_now() |> DateTime.to_string()
                ])
              end

              table do
                table_row(["Column 1", "Column 2", "Column 3"])
                table_row(["a", "b", "c"])
                table_row(["d", "e", "f"])
              end

              table do
                table_row(["Random Number:", inspect(:rand.uniform())])

                table_row([
                  "Hello:",
                  String.duplicate("World", Enum.random(1..3))
                ])
              end
            end
          end

          column(size: 9) do
            panel title: "Column 2 Row 2" do
              sparkline(Enum.shuffle([0, 1, 2, 3, 4, 5, 6]))

              table do
                table_row([
                  "Current Time:",
                  DateTime.utc_now() |> DateTime.to_string()
                ])
              end

              table do
                table_row(["Column 1", "Column 2", "Column 3"])
                table_row(["a", "b", "c"])
                table_row(["d", "e", "f"])
              end

              table do
                table_row(["Random Number:", inspect(:rand.uniform())])

                table_row([
                  "Hello:",
                  String.duplicate("World", Enum.random(1..3))
                ])
              end
            end
          end
        end
      end
    end
  end
end

RenderingDemo.run()
