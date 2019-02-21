defmodule Ratatouille.RuntimeTest do
  use ExUnit.Case, async: true

  alias Ratatouille.{Constants, EventManager, Runtime, Window}

  defmodule BindingsStub do
    use Ratatouille.Stub

    deftracked init, do: :ok
    deftracked poll_event(_), do: :ok
    deftracked select_input_mode(_), do: :ok
    deftracked select_output_mode(_), do: :ok
    deftracked shutdown, do: :ok
    deftracked clear, do: :ok
    deftracked present, do: :ok
    deftracked put_cell(_), do: :ok
    deftracked height, do: 42
    deftracked width, do: 81
  end

  defmodule AppStub do
    use Ratatouille.Stub

    import Ratatouille.View

    deftracked init(context) do
      0
    end

    deftracked update(model, event) do
      model + 1
    end

    deftracked render(model) do
      view do
        label(content: to_string(model))
      end
    end
  end

  setup do
    _ = start_supervised!(BindingsStub)
    _ = start_supervised!(AppStub)

    window =
      start_supervised!({Window, name: nil, bindings: BindingsStub},
        restart: :transient
      )

    event_manager =
      start_supervised!({EventManager, name: nil, bindings: BindingsStub})

    pid =
      start_supervised!(
        {Runtime, app: AppStub, window: window, event_manager: event_manager}
      )

    %{pid: pid}
  end

  describe "application loop" do
    test "handles quit events (q)", %{pid: pid} do
      ref = Process.monitor(pid)

      send(pid, {:event, %{ch: ?q}})
      assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
    end

    test "handles quit events (ctrl-c)", %{pid: pid} do
      ref = Process.monitor(pid)

      send(pid, {:event, %{key: Constants.key(:ctrl_c)}})
      assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
    end

    test "handles application setup", %{pid: pid} do
      wait_for_quit(pid)

      assert [
               {:render, 0},
               {:init, %{window: %{height: 42, width: 81}}}
             ] = AppStub.calls()
    end

    test "calls application's update function with resize events", %{pid: pid} do
      send(pid, {:event, %{type: Constants.event_type(:resize)}})
      wait_for_quit(pid)

      assert [
               {:render, 1},
               {:update, 0, {:resize, %{}}}
               | _
             ] = AppStub.calls()
    end

    test "passes on other events to application's update function", %{pid: pid} do
      send(pid, {:event, %{ch: ?a}})
      wait_for_quit(pid)

      assert [
               {:render, 1},
               {:update, 0, {:event, %{ch: ?a}}}
               | _
             ] = AppStub.calls()
    end
  end

  describe "window setup" do
    test "initializes the bindings via Window", %{pid: pid} do
      wait_for_quit(pid)

      assert [:init | _] = Enum.reverse(BindingsStub.calls())
    end
  end

  # By quitting and waiting for the runtime to stop itself, we know that all
  # events were processed.
  defp wait_for_quit(pid) do
    ref = Process.monitor(pid)
    send(pid, {:event, %{ch: ?q}})

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end
end
