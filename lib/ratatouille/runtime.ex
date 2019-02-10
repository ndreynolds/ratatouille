defmodule Ratatouille.Runtime do
  @moduledoc """
  A runtime for apps implementing the `Ratatouille.App` behaviour. See
  `Ratatouille.App` for details on how to build apps.

  ## Runtime Context

  The runtime provides a map with additional context to the app's
  `c:Ratatouille.App.model/1` callback. This can be used, for example,
  to get information about the terminal window.  Currently, the following
  attributes are provided via the map:

  * `:window`: A map with `:height` and `:width` keys.

  ## Shutdown Options

  * `:window`: Resets the terminal window and stops the runtime process.
    Afterwards the system will still be running unless stopped elsewhere.
  * `{:system, :stop}`: Resets the terminal window and gracefully stops the
    system (calls `:init.stop/0`). Gracefully shutting down the VM ensures that
    all applications are stopped, but it takes at least one second which results
    in a noticeable lag.
  * `{:system, :halt}`: Resets the terminal window and immediately halts the
    system (calls `:erlang.halt/0`). Applications are not cleanly stopped, but
    this maybe be reasonable for some use cases.
  * `{:application, name}` - Resets the terminal window and stops the named
    application. Afterwards the rest of the system will still be running unless
    stopped elsewhere.

  """

  use Task, restart: :transient

  alias Ratatouille.{EventManager, Window}

  import Ratatouille.Constants, only: [event_type: 1, key: 1]

  @default_interval_ms 500

  @default_quit_events [
    {:ch, ?q},
    {:ch, ?Q},
    {:key, key(:ctrl_c)}
  ]

  @resize_event event_type(:resize)

  @doc """
  Starts the application runtime given a module defining a Ratatouille terminal
  application.

  ## Options

  * `:app` (required) - The `Ratatouille.App` to run.
  * `:shutdown` - The strategy for stopping the terminal application when a quit
     event is received.
  * `:interval` - Tick interval in milliseconds. The default interval is 500 ms.
  * `:quit_events` - Specifies the events that should quit the terminal
    application. Given as a list of tuples conforming where each tuple conforms
    to either `{:ch, ch}` or `{:key, key}`. If not specified, ctrl-c and q / Q
    can be used to quit the application by default.
  """
  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(opts) do
    app = Keyword.fetch!(opts, :app)

    opts_with_defaults =
      Keyword.merge(
        [
          event_manager: EventManager,
          window: Window,
          shutdown: :window,
          interval: @default_interval_ms,
          quit_events: @default_quit_events
        ],
        opts
      )

    Task.start_link(__MODULE__, :run, [app, opts_with_defaults])
  end

  @spec run(module(), Keyword.t()) :: :ok
  def run(app, opts) do
    :ok = EventManager.subscribe(opts[:event_manager], self())

    model =
      opts
      |> context()
      |> app.model()
      |> app.update(:tick)

    loop(app, model, opts)
  end

  defp loop(app, model, opts) do
    window = Keyword.fetch!(opts, :window)
    interval = Keyword.fetch!(opts, :interval)
    quit_events = Keyword.fetch!(opts, :quit_events)

    :ok = Window.update(window, app.render(model))

    receive do
      {:event, %{type: @resize_event} = event} ->
        new_model = app.update(model, {:resize, event})
        loop(app, new_model, opts)

      {:event, event} ->
        if quit_event?(quit_events, event) do
          shutdown(opts)
        else
          new_model = app.update(model, {:event, event})
          loop(app, new_model, opts)
        end
    after
      interval ->
        new_model = app.update(model, :tick)
        loop(app, new_model, opts)
    end
  end

  defp context(opts) do
    window = Keyword.fetch!(opts, :window)

    %{window: window_info(window)}
  end

  defp window_info(window) do
    {:ok, height} = Window.fetch(window, :height)
    {:ok, width} = Window.fetch(window, :width)
    %{height: height, width: width}
  end

  defp quit_event?([], _event), do: false
  defp quit_event?([{:ch, ch} | _], %{ch: ch}), do: true
  defp quit_event?([{:key, key} | _], %{key: key}), do: true
  defp quit_event?([_ | events], event), do: quit_event?(events, event)

  defp shutdown(opts) do
    window = Keyword.fetch!(opts, :window)
    shutdown = Keyword.fetch!(opts, :shutdown)

    :ok = Window.close(window)

    case shutdown do
      {:application, app} -> Application.stop(app)
      {:system, :stop} -> System.stop()
      {:system, :halt} -> System.halt()
      :window -> :ok
    end
  end
end
