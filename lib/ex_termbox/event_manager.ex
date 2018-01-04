defmodule ExTermbox.EventManager do
  @moduledoc """
  This module implements an event manager that notifies subscribers of the
  keyboard, mouse and resize events received from the termbox API.

  It works by running a poll loop that calls out to the NIFs in
  `ExTermbox.Bindings`:

    1. The `ExTermbox.Bindings.poll_event/1` NIF is called with the event
       manager's pid.
    2. The NIF creates a new thread for the blocking poll routine and
       immediately returns with a resource representing a handle for the thread.
    3. The thread blocks until an event is received (e.g., a keypress), at which
       point it sends a message to the event manager with the event data and
       exits.
    4. The event manager notifies its subscribers of the event and returns to
       step 1.

  Example Usage:

      alias ExTermbox.{EventManager, Event}

      {:ok, pid} = EventManager.start_link()
      :ok = EventManager.subscribe(self())

      receive do
        {:event, %Event{ch: ?q} = event} ->
          Window.close()
        {:event, %Event{} = event} ->
          # handle the event and wait for another...
          event_loop()
      end
  """

  alias ExTermbox.{Bindings, Event}

  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def subscribe(server_pid, subscriber_pid) do
    GenServer.call(server_pid, {:subscribe, subscriber_pid})
  end

  # Server Callbacks

  def init(:ok) do
    start_polling()
    {:ok, MapSet.new()}
  end

  def handle_call({:subscribe, pid}, _from, recipients) do
    {:reply, :ok, MapSet.put(recipients, pid)}
  end

  def handle_info({:event, event_tuple}, recipients) do
    event = unpack_event(event_tuple)
    notify(recipients, event)
    start_polling() # Start polling for the next event
    {:noreply, recipients}
  end

  def start_polling do
    server_pid = self()
    spawn(fn -> Bindings.poll_event_async(server_pid) end)
  end

  defp notify(recipients, event) do
    for pid <- recipients do
      send(pid, {:event, event})
    end
  end

  defp unpack_event({type, mod, key, ch, w, h, x, y}),
    do: %Event{type: type, mod: mod, key: key, ch: ch, w: w, h: h, x: x, y: y}
end
