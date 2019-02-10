defmodule Ratatouille.EventManager do
  @moduledoc """
  A wrapper of `ExTermbox.EventManager` so that Ratatouille applications don't
  need to use or depend on ex_termbox directly.
  """

  @doc """
  Starts the `ExTermbox.EventManager` gen_server.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    opts_with_defaults = Keyword.merge([name: __MODULE__], opts)

    ExTermbox.EventManager.start_link(opts_with_defaults)
  end

  @doc """
  Subscribes the given pid to future event notifications.
  """
  defdelegate subscribe(pid \\ __MODULE__, subscriber_pid),
    to: ExTermbox.EventManager

  @doc """
  Provides a child specification to use when starting the event manager under a
  supervisor.
  """
  defdelegate child_spec(opts), to: ExTermbox.EventManager
end
