defmodule Ratatouille.Runtime do
  @moduledoc """
  A runtime for apps implementing the `Ratatouille.App` behaviour. See
  `Ratatouille.App` for details on how to build apps.

  ## Runtime Context

  The runtime provides a map with additional context to the app's
  `Ratatouille.App.model/1` callback. This can be used, for example,
  to get information about the terminal window.  Currently, the following
  attributes are provided via the map:

  * `:window`: A map with `:height` and `:width` keys.

  """

  use Task, restart: :transient

  alias Ratatouille.{EventManager, Window}

  import Ratatouille.Constants, only: [event_type: 1, key: 1]

  @default_interval_ms 500

  @resize_event event_type(:resize)
  @ctrl_c key(:ctrl_c)

  @doc """
  Starts the application runtime given a module defining a Ratatouille terminal
  application.

  ## Options

  * `:app` (required) - The `Ratatouille.App` to run.
  * `:shutdown` - The strategy for stopping the terminal application when the
    user quits to be passed to the runtime. Can be `:system` to call
    `System.stop/0` or a tuple `{:application, name}` to stop the given
    application. By default, the runtime processes stops and no additional
    cleanup is done.
  * `:interval` - Tick interval in milliseconds. The default interval is 500 ms.
  """
  def start_link(opts) do
    app = Keyword.fetch!(opts, :app)

    Task.start_link(__MODULE__, :run, [app, opts])
  end

  def run(app, opts) do
    :ok = EventManager.subscribe(self())

    model = context() |> app.model() |> app.update(:tick)

    loop(app, model, opts)
  end

  defp loop(app, model, opts) do
    interval = opts[:interval] || @default_interval_ms

    Window.update(app.render(model))

    receive do
      {:event, %{ch: ch, key: key}} when ch in [?q, ?Q] or key == @ctrl_c ->
        shutdown(opts)

      {:event, %{type: @resize_event} = event} ->
        new_model = app.update(model, {:resize, event})
        loop(app, new_model, opts)

      {:event, event} ->
        new_model = app.update(model, {:event, event})
        loop(app, new_model, opts)
    after
      interval ->
        new_model = app.update(model, :tick)
        loop(app, new_model, opts)
    end
  end

  defp context do
    %{window: window_info()}
  end

  defp window_info do
    {:ok, height} = Window.fetch(:height)
    {:ok, width} = Window.fetch(:width)
    %{height: height, width: width}
  end

  defp shutdown(opts) do
    case opts[:shutdown] do
      {:application, app} ->
        Application.stop(app)

      :system ->
        System.stop()

      _ ->
        Window.close()
    end
  end
end
