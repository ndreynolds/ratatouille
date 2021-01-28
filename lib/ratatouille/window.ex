defmodule Ratatouille.Window do
  @moduledoc """
  A GenServer to manage the terminal window, along with a client API to perform
  updates and retrieve window information.
  """

  use GenServer

  alias Ratatouille.Constants
  alias Ratatouille.Renderer
  alias Ratatouille.Renderer.{Canvas, Element}

  @default_bindings ExTermbox.Bindings
  @default_input_mode Constants.input_mode(:esc)
  @default_output_mode Constants.output_mode(:normal)

  ### Client

  @doc """
  Starts the gen_server representing the window.

  The window is intended to be run as a singleton gen_server process, as
  initializing the underlying termbox library multiple times on the same TTY can
  lead to undefined behavior.

  ## Options

  * `:name`        - Override the name passed to `GenServer.start_link/3`. By
                     default, `name: Ratatouille.Window` is passed in order to
                     protect against accidental double initialization, but this
                     can be overridden by passing `nil` or an alternate value.
  * `:input_mode`  - Configure the input mode. See `Ratatouille.Constants.input_mode/1`
                     for possible values.
  * `:output_mode` - Configure the output mode. See `Ratatouille.Constants.output_mode/1`
                     for possible values.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    {init_opts, server_opts} =
      Keyword.split(opts, [:bindings, :input_mode, :output_mode])

    defaulted_init_opts =
      Map.merge(
        %{
          bindings: @default_bindings,
          input_mode: @default_input_mode,
          output_mode: @default_output_mode
        },
        Enum.into(init_opts, %{})
      )

    defaulted_server_opts = Keyword.merge([name: __MODULE__], server_opts)

    GenServer.start_link(
      __MODULE__,
      defaulted_init_opts,
      defaulted_server_opts
    )
  end

  @doc """
  Updates the window by rendering the given view to the termbox buffer and
  presenting it.
  """
  @spec update(GenServer.server(), Element.t()) :: :ok
  def update(pid \\ __MODULE__, view), do: GenServer.call(pid, {:update, view})

  @doc """
  Closes the window by stopping the GenServer. Prior to this, termbox is
  de-initialized so that the terminal is restored to its previous state.
  """
  @spec close(GenServer.server()) :: :ok
  def close(pid \\ __MODULE__), do: GenServer.stop(pid)

  @type fetch_attr :: :width | :height | :box

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
  @spec fetch(GenServer.server(), fetch_attr()) :: term()
  def fetch(pid \\ __MODULE__, attr), do: GenServer.call(pid, {:fetch, attr})

  ### Server

  @impl true
  def init(%{
        bindings: bindings,
        input_mode: input_mode,
        output_mode: output_mode
      }) do
    Process.flag(:trap_exit, true)

    :ok = bindings.init()
    {:ok, _mode} = bindings.select_input_mode(input_mode)
    {:ok, _mode} = bindings.select_output_mode(output_mode)

    {:ok, %{bindings: bindings, screen_buffer: %{}}}
  end

  @impl true
  def handle_call(
        {:update, view},
        _from,
        %{bindings: bindings, screen_buffer: screen_buffer} = state
      ) do
    {:ok, updated_buffer} = render_view(bindings, view, screen_buffer)
    {:reply, :ok, %{state | screen_buffer: updated_buffer}}
  end

  @impl true
  def handle_call(:clear, _from, %{bindings: bindings} = state) do
    :ok = clear(bindings)
    {:reply, :ok, %{state | screen_buffer: %{}}}
  end

  @impl true
  def handle_call({:fetch, attr}, _from, %{bindings: bindings} = state) do
    {:reply, fetch_attr(bindings, attr), state}
  end

  @impl true
  def terminate(_reason, %{bindings: bindings}) do
    case bindings.shutdown() do
      :ok -> :normal
      err -> {:error, err}
    end
  end

  defp fetch_attr(bindings, attr) do
    case attr do
      :width -> bindings.width()
      :height -> bindings.height()
      :box -> {:ok, canvas(bindings).outer_box}
      _ -> {:error, :unknown_attribute}
    end
  end

  defp clear(bindings) do
    :ok = bindings.clear()
    :ok = bindings.present()
    :ok
  end

  defp render_view(bindings, view, screen_buffer) do
    with empty_canvas <- canvas(bindings),
         {:ok, filled_canvas} <- Renderer.render(empty_canvas, view),
         {:ok, updated_buffer} <-
           Canvas.render_to_termbox(bindings, filled_canvas, screen_buffer) do
      :ok = bindings.present()
      {:ok, updated_buffer}
    end
  end

  defp canvas(bindings) do
    with {:ok, width} <- bindings.width(),
         {:ok, height} <- bindings.height() do
      Canvas.from_dimensions(width, height)
    end
  end
end
