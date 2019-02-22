defmodule Ratatouille.ExamplesTest do
  @moduledoc """
  This test ensures that the examples can all be started and quit.

  Because the examples use the real termbox bindings and start named processes,
  these tests should be run separately from the unit tests.
  """

  use ExUnit.Case, async: false

  alias ExTermbox.Event
  alias Ratatouille.{EventManager, Window}

  import Ratatouille.Constants, only: [key: 1]

  @examples_root Path.join(Path.dirname(__ENV__.file), "../../examples")
  @examples Path.wildcard("#{@examples_root}/*.exs")

  @ctrl_d key(:ctrl_d)

  setup do
    on_exit(fn ->
      # Clean up anything that wasn't properly shut down.

      event_manager = Process.whereis(EventManager)

      if is_pid(event_manager) do
        :ok = GenServer.stop(event_manager, :normal)
      end

      window = Process.whereis(Window)

      if is_pid(window) do
        :ok = GenServer.stop(window, :normal)
      end
    end)

    :ok
  end

  test "at least one example was found" do
    assert [_ | _] = @examples
  end

  for example_path <- @examples do
    @example_path example_path
    @example_basename Path.basename(example_path)

    @tag :integration
    test "running example '#{@example_basename}' succeeds" do
      pid = spawn(fn -> Code.eval_file(@example_path) end)
      ref = Process.monitor(pid)

      # TODO: Try waiting for something to happen instead of sleeping.
      # It's tricky because the window and event manager are started
      # concurrently within the spawn. But logging something and tracing calls
      # to the logger could work.
      Process.sleep(300)

      assert Process.alive?(pid)

      event_manager = Process.whereis(EventManager)
      assert Process.alive?(event_manager)

      # Try all the ways of quitting used
      simulate_event(event_manager, %Event{type: 1, key: @ctrl_d})
      simulate_event(event_manager, %Event{type: 1, ch: ?q})

      assert_receive({:DOWN, ^ref, :process, ^pid, :normal}, 2_000)
      refute Process.alive?(pid)
    end
  end

  def simulate_event(pid, event), do: send(pid, {:event, event})
end
