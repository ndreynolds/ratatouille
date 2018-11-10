defmodule HelloWorld do
  @moduledoc """
  This is a simple terminal application to show how to get started.
  """

  alias ExTermbox.{EventManager, Event, Window}
  import ExTermbox.Renderer.View

  def run do
    # This initializes the application, drawing a blank canvas over the
    # terminal.
    {:ok, _pid} = Window.start_link()

    # In order to react to keyboard, click or resize events, we need to start
    # the event manager and subscribe the current process to any events.
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())

    # Next, we define a view. Similar to HTML, views are defined as a tree of
    # nodes. Nodes have attributes (e.g., text: bold) and children (nested
    # content). Every view must start with a root `view` element.
    hello_world_view =
      view do
        panel title: "Hello, World!", height: :fill do
          element(:text, ["Press 'q' to quit."])
        end
      end

    # Building a view only defines it. To render it to the screen, we need to
    # use the `Window.update/1` function.
    :ok = Window.update(hello_world_view)

    # When a key is pressed, it'll be sent to us by the event manager. Once we
    # receive a 'q' key press, we'll close the application.
    receive do
      {:event, %Event{ch: ?q}} ->
        :ok = Window.close()
    end
  end
end

HelloWorld.run()
