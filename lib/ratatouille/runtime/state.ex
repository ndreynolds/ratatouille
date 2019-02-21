defmodule Ratatouille.Runtime.State do
  @moduledoc """
  Defines a struct to store the runtime loop's state.
  """

  @enforce_keys [:app, :window, :event_manager, :interval]
  defstruct [
    :app,
    :model,
    :window,
    :event_manager,
    :supervisor,
    :shutdown,
    :interval,
    :quit_events,
    :subscriptions
  ]
end
