defmodule Ratatouille.Runtime do
  @moduledoc """
  A runtime for apps implementing the `Ratatouille.App` behaviour. See
  `Ratatouille.App` for details on how to build apps.

  ## Runtime Context

  The runtime provides a map with additional context to the app's
  `c:Ratatouille.App.init/1` callback. This can be used, for example,
  to get information about the terminal window.  Currently, the following
  attributes are provided via the map:

  * `:window`: A map with `:height` and `:width` keys.

  ## Shutdown Options

  When a quit event is received (by default, "q", "Q" or ctrl-c), the runtime
  will carry out the configured shutdown strategy. The default strategy
  (`:self`) just stops the runtime process itself. In certain cases, it may
  be desirable to stop an OTP application or the system itself, so a few other
  strategies are provided:

  * `:supervisor` - Stops the runtime supervisor, which will terminate the
    runtime process and other dependencies. The VM will still be running
    afterwards unless stopped by other means.
  * `{:application, name}` - Stops the named application. The VM will still be
    running afterwards unless stopped by other means.
  * `:system`: Gracefully stops the system (calls `:init.stop/0`). Gracefully
    shutting down the VM ensures that all applications are stopped. There will
    be some lag between sending the quit event and the OS process actually
    exiting, as the VM needs about a second to stop this way. See the note below
    if this is a problem.

  If the `:system` option is too slow, it's possible to halt the system manually
  with `System.halt/0`. It's just important to ensure that the system is only
  halted after the terminal was restored to its original state. Otherwise, there
  may be rendering artifacts or issues with the cursor. The `:supervisor` option
  can be used to properly halt the system by monitoring the runtime supervisor
  and halting once it has exited. Alternatively, use the `:application` option
  to stop an application that runs the runtime supervisor and halt in the
  application's `stop/1` callback.
  """

  use Task, restart: :transient

  alias Ratatouille.{EventManager, Window}
  alias Ratatouille.Runtime.{Command, State, Subscription}

  import Ratatouille.Constants, only: [event_type: 1, key: 1]

  require Logger

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

  ## Configuration

  * `:app` (required) - The `Ratatouille.App` to run.
  * `:shutdown` - The strategy for stopping the terminal application when a quit
     event is received.
  * `:interval` - The runtime loop interval in milliseconds. The default
     interval is 500 ms. A subscription can be fulfilled at most once every
     interval, so this effectively configures the maximum subscription
     resolution that's possible.
  * `:quit_events` - Specifies the events that should quit the terminal
     application. Given as a list of tuples conforming where each tuple conforms
     to either `{:ch, ch}` or `{:key, key}`. If not specified, ctrl-c and q / Q
     can be used to quit the application by default.
  """
  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(config) do
    state = %State{
      app: Keyword.fetch!(config, :app),
      supervisor: Keyword.get(config, :supervisor),
      event_manager: Keyword.get(config, :event_manager, EventManager),
      window: Keyword.get(config, :window, Window),
      shutdown: Keyword.get(config, :shutdown, :self),
      interval: Keyword.get(config, :interval, @default_interval_ms),
      quit_events: Keyword.get(config, :quit_events, @default_quit_events)
    }

    Task.start_link(__MODULE__, :run, [state])
  end

  @spec run(State.t()) :: :ok
  def run(state) do
    :ok = EventManager.subscribe(state.event_manager, self())

    model = initial_model(state)

    subscriptions =
      if function_exported?(state.app, :subscribe, 1) do
        model |> state.app.subscribe() |> Subscription.to_list()
      else
        []
      end

    loop(%State{state | model: model, subscriptions: subscriptions})
  rescue
    # We rescue any exceptions so that we can be sure they're printed to the
    # screen.
    e ->
      formatted_exception = Exception.format(:error, e, __STACKTRACE__)

      abort(
        state.window,
        "Error in application loop:\n  #{formatted_exception}"
      )
  end

  defp loop(state) do
    :ok = Window.update(state.window, state.app.render(state.model))

    receive do
      {:event, %{type: @resize_event} = event} ->
        state
        |> process_update({:resize, event})
        |> loop()

      {:event, event} ->
        if quit_event?(state.quit_events, event) do
          shutdown(state)
        else
          state
          |> process_update({:event, event})
          |> loop()
        end

      {:command_result, message} ->
        state
        |> process_update(message)
        |> loop()
    after
      state.interval ->
        state
        |> process_subscriptions()
        |> loop()
    end
  end

  defp initial_model(state) do
    ctx = context(state)

    case state.app.init(ctx) do
      {model, %Command{} = command} ->
        :ok = process_command_async(command)
        model

      model ->
        model
    end
  end

  defp process_update(state, message) do
    case state.app.update(state.model, message) do
      {model, %Command{} = command} ->
        :ok = process_command_async(command)
        %State{state | model: model}

      model ->
        %State{state | model: model}
    end
  end

  defp process_subscriptions(state) do
    {new_subs, new_state} =
      Enum.map_reduce(state.subscriptions, state, fn sub, state_acc ->
        process_subscription(state_acc, sub)
      end)

    %State{new_state | subscriptions: new_subs}
  end

  defp process_subscription(state, sub) do
    case sub do
      %Subscription{type: :interval, data: {interval_ms, last_at_ms}} ->
        now = :erlang.monotonic_time(:millisecond)

        if last_at_ms + interval_ms <= now do
          new_sub = %Subscription{sub | data: {interval_ms, now}}
          new_state = process_update(state, sub.message)
          {new_sub, new_state}
        else
          {sub, state}
        end

      _ ->
        {sub, state}
    end
  end

  defp process_command_async(command) do
    runtime_pid = self()

    for cmd <- Command.to_list(command) do
      # TODO: This is missing a few things:
      # - Need to capture failures and report them via the update/2 callback.
      #   - Could be as simple as {:ok, result} | {:error, error}
      # - Should provide a timeout mechanism with sensible defaults. This should
      #   help prevent h
      {:ok, _pid} =
        Task.start(fn ->
          result = cmd.function.()
          send(runtime_pid, {:command_result, {cmd.message, result}})
        end)
    end

    :ok
  end

  defp context(state) do
    %{window: window_info(state.window)}
  end

  defp window_info(window) do
    {:ok, height} = Window.fetch(window, :height)
    {:ok, width} = Window.fetch(window, :width)
    %{height: height, width: width}
  end

  defp abort(window, error_msg) do
    :ok = Window.close(window)

    Logger.error(error_msg)

    Logger.warn(
      "The Ratatouille termbox window was automatically closed due " <>
        "to an error (you may need to quit Erlang manually)."
    )

    :ok
  end

  defp shutdown(state) do
    case state.shutdown do
      :supervisor -> Supervisor.stop(state.supervisor)
      {:application, app} -> Application.stop(app)
      :system -> System.stop()
      :self -> :ok
    end
  end

  defp quit_event?([], _event), do: false
  defp quit_event?([{:ch, ch} | _], %{ch: ch}), do: true
  defp quit_event?([{:key, key} | _], %{key: key}), do: true
  defp quit_event?([_ | events], event), do: quit_event?(events, event)
end
