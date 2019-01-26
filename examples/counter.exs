defmodule Counter do
  @behaviour Ratatouille.App

  import Ratatouille.View

  def model(_context), do: 0

  def update(model, msg) do
    case msg do
      {:event, %{ch: ?+}} -> model + 1
      {:event, %{ch: ?-}} -> model - 1
      _ -> model
    end
  end

  def render(model) do
    view do
      label(content: "Counter is #{model} (+/-)")
    end
  end
end

# Now start the runtime and wait for it to stop
# (Stops when user presses 'q' or ctrl-c.)

{:ok, _} = Ratatouille.Window.start_link()
{:ok, _} = Ratatouille.EventManager.start_link()
{:ok, runtime_pid} = Ratatouille.Runtime.start_link(app: Counter)

ref = Process.monitor(runtime_pid)

receive do
  {:DOWN, ^ref, _, _, _} -> :ok
end
