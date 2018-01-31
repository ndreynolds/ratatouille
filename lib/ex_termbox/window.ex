defmodule ExTermbox.Window do
  @moduledoc """
  A GenServer to manage the terminal window, along with a client API to perform
  updates and retrieve window information.
  """

  use GenServer

  alias ExTermbox.Bindings
  alias ExTermbox.Renderer
  alias ExTermbox.Renderer.{Canvas, View}

  @name {:global, :extb_window_server}

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def open(view \\ View.default_view()),
    do: GenServer.call(@name, {:open, view})

  def update(view), do: GenServer.call(@name, {:update, view})

  def close, do: GenServer.stop(@name)

  def fetch(attr), do: GenServer.call(@name, {:fetch, attr})

  def init(:ok) do
    Process.flag(:trap_exit, true)
    :ok = Bindings.init()
    {:ok, {}}
  end

  def handle_call({:open, view}, _from, state) do
    {:reply, render_view(view), state}
  end

  def handle_call({:update, view}, _from, state) do
    :ok = Bindings.clear()
    {:reply, render_view(view), state}
  end

  def handle_call({:fetch, attr}, _from, state) do
    {:reply, fetch_attr(attr), state}
  end

  def terminate(_reason, _state) do
    case Bindings.shutdown() do
      :ok -> :normal
      err -> {:error, err}
    end
  end

  defp fetch_attr(attr) do
    case attr do
      :width -> {:ok, Bindings.width()}
      :height -> {:ok, Bindings.height()}
      :box -> {:ok, canvas().box}
      _ -> {:error, :unknown_attribute}
    end
  end

  defp render_view(view) do
    canvas()
    |> Renderer.render(view)
    |> Canvas.render_to_termbox()

    :ok = Bindings.present()
  end

  defp canvas do
    Canvas.from_dimensions(
      Bindings.width(),
      Bindings.height()
    )
  end
end
