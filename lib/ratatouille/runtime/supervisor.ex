defmodule Ratatouille.Runtime.Supervisor do
  @moduledoc """
  A supervisor to run the application runtime and its dependencies.
  """

  use Supervisor

  alias Ratatouille.{EventManager, Runtime, Window}

  ### Client

  @doc """
  Starts a supervisor that manages `Ratatouille.Runtime`, along with runtime
  dependencies `Ratatouille.EventManager` and `Ratatouille.Window`.

  ## Options

  * `:runtime` - Options for the runtime. See `Ratatouille.Runtime.start_link/1`.
  """
  @spec start_link(Keyword.t()) :: {:ok, pid()} | :ignore | {:error, term()}
  def start_link(opts \\ []) do
    {child_opts, sup_opts} = Keyword.split(opts, [:app, :runtime])

    Supervisor.start_link(__MODULE__, child_opts, sup_opts)
  end

  ### Supervisor (callbacks)

  @impl true
  def init(opts) do
    runtime_opts =
      Keyword.merge(
        [shutdown: :supervisor, supervisor: self()],
        opts[:runtime] || []
      )

    children = [
      %{
        id: EventManager,
        start: {EventManager, :start_link, []},
        restart: :transient
      },
      %{
        id: Window,
        start: {Window, :start_link, []},
        restart: :transient
      },
      %{
        id: Runtime,
        start: {Runtime, :start_link, [runtime_opts]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
