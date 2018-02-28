defmodule ExTermbox.Window do
  @moduledoc """
  A GenServer to manage the terminal window, along with a client API to perform
  updates and retrieve window information.
  """

  use GenServer

  alias ExTermbox.Bindings
  alias ExTermbox.Renderer
  alias ExTermbox.Renderer.{Canvas, Element}

  @name {:global, :extb_window_server}

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @doc """
  Updates the window by rendering the given view to the termbox buffer and
  presenting it.
  """
  @spec update(Element.t()) :: :ok
  def update(view), do: GenServer.call(@name, {:update, view})

  @doc """
  Closes the window by stopping the GenServer. Prior to this, termbox is
  de-initialized so that the terminal is restored to its previous state.
  """
  @spec close :: :ok
  def close, do: GenServer.stop(@name)

  @doc """
  Fetches an attribute for the window. This is currently limited to the window
  dimensions, which can be useful when laying out content.

  ## Examples

      iex> Window.fetch(:height)
      {:ok, 124}
      iex> Window.fetch(:width)
      {:ok, 50}
      iex> Window.fetch(:foo)
      {:error, :unknown_attribute}

  """
  @spec fetch(atom()) :: any()
  def fetch(attr), do: GenServer.call(@name, {:fetch, attr})

  def init(:ok) do
    Process.flag(:trap_exit, true)
    :ok = Bindings.init()
    {:ok, {}}
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
