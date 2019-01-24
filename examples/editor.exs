defmodule Editor do
  @moduledoc """
  A sample application that shows how to accept user input and render it to the
  terminal.

  Supports editing a single line of text with support for entering characters
  and spaces and deleting them. No support moving the cursor or multiline
  entry---that's left as an exercise for the reader.
  """

  alias Ratatouille.{EventManager, Window}

  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]

  @title "Editor (CTRL-d to quit)"

  @ctrl_d key(:ctrl_d)
  @spacebar key(:space)

  @delete_keys [
    key(:delete),
    key(:backspace),
    key(:backspace2)
  ]

  def start do
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    loop("")
  end

  def loop(text) do
    text
    |> render()
    |> Window.update()

    receive do
      {:event, %{key: @ctrl_d}} ->
        :ok = Window.close()

      {:event, %{key: key}} when key in @delete_keys ->
        loop(String.slice(text, 0..-2))

      {:event, %{key: @spacebar}} ->
        loop(text <> " ")

      {:event, %{ch: ch}} when ch > 0 ->
        loop(text <> <<ch::utf8>>)
    end
  end

  def render(text) do
    view do
      panel title: @title do
        label(content: text <> "▌")
      end
    end
  end
end

Editor.start()
