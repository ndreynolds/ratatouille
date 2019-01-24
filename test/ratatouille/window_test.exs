defmodule Ratatouille.WindowTest do
  use ExUnit.Case, async: true

  alias Ratatouille.{Constants, Renderer.Box, Window}

  alias ExTermbox.Position

  import Ratatouille.View

  # Since the `ExTermbox.Bindings` NIFs are imperative with troublesome side
  # effects, we configure the test windows to use this stub instead.
  #
  # The stub is an `Agent` that remembers its calls so that the bindings usage
  # can be verified.
  defmodule BindingsStub do
    use Agent

    def start_link(opts) do
      Agent.start_link(fn -> [] end, opts)
    end

    def init, do: track(:init)
    def clear, do: track(:clear)
    def present, do: track(:present)
    def shutdown, do: track(:shutdown)
    def select_input_mode(mode), do: track({:select_input_mode, mode})
    def select_output_mode(mode), do: track({:select_output_mode, mode})

    def width, do: 42
    def height, do: 81

    defp track(call) do
      Agent.update(__MODULE__, fn calls -> [call | calls] end)
    end
  end

  setup do
    _pid = start_supervised!({BindingsStub, name: BindingsStub})

    pid =
      start_supervised!({Window, name: nil, bindings: BindingsStub},
        restart: :transient
      )

    %{pid: pid}
  end

  @input_mode_esc Constants.input_mode(:esc)
  @output_mode_normal Constants.output_mode(:normal)

  describe "start_link/1" do
    test "returns tagged tuple with pid and initializes the terminal" do
      assert {:ok, pid} = Window.start_link()

      assert is_pid(pid)

      assert [
               {:select_output_mode, @output_mode_normal},
               {:select_input_mode, @input_mode_esc},
               :init
             ] = bindings_calls()
    end
  end

  describe "update/2" do
    test "renders a view via clear/0 and present/0", %{pid: pid} do
      view = view()
      assert :ok = Window.update(pid, view)
      assert [:present, :clear | _] = bindings_calls()
    end
  end

  describe "close/1" do
    test "stops the gen_server and calls bindings.shutdown/0", %{pid: pid} do
      assert :ok = Window.close(pid)
      assert [:shutdown | _] = bindings_calls()
    end
  end

  describe "fetch/2" do
    test "returns width from bindings.width/0", %{pid: pid} do
      assert {:ok, 42} = Window.fetch(pid, :width)
    end

    test "returns height from bindings.height/0", %{pid: pid} do
      assert {:ok, 81} = Window.fetch(pid, :height)
    end

    test "returns box based on height and width", %{pid: pid} do
      assert {:ok,
              %Box{
                top_left: %Position{x: 0, y: 0},
                bottom_right: %Position{x: 41, y: 80}
              }} = Window.fetch(pid, :box)
    end

    test "return error given unknown attribute", %{pid: pid} do
      assert {:error, :unknown_attribute} = Window.fetch(pid, :foo)
    end
  end

  defp bindings_calls, do: Agent.get(BindingsStub, & &1)
end
