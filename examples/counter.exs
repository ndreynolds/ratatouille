# Run this example with:
#
#   mix run --no-halt examples/counter.exs

defmodule Counter do
  @behaviour Ratatouille.App

  import Ratatouille.View

  def init(_context), do: 0

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

{:ok, _pid} =
  Ratatouille.Runtime.Supervisor.start_link(
    runtime: [app: Counter, shutdown: {:system, :halt}]
  )
