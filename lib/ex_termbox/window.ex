defmodule ExTermbox.Window do
  use GenServer

  alias ExTermbox.Bindings
  alias ExTermbox.Renderer
  alias ExTermbox.Renderer.{Box, View}

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
      :box -> {:ok, window_box()}
      _ -> {:error, :unknown_attribute}
    end
  end

  defp render_view(view) do
    Renderer.render(window_box(), view)
    :ok = Bindings.present()
  end

  defp window_box, do: Box.from_dimensions(Bindings.width(), Bindings.height())
end
