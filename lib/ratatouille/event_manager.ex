defmodule Ratatouille.EventManager do
  @moduledoc """
  A convenience wrapper of `ExTermbox.EventManager`.
  """

  alias ExTermbox.EventManager, as: TermboxEventManager

  @doc """
  Starts the `ExTermbox.EventManager` gen_server.
  """
  defdelegate start_link, to: TermboxEventManager

  @doc """
  Subscribes the given pid to future event notifications.
  """
  defdelegate subscribe(subscriber_pid), to: TermboxEventManager
end
