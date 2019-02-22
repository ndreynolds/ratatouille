defmodule Ratatouille do
  @moduledoc """
  Ratatouille is a framework for building terminal UIs.
  """

  alias Ratatouille.Runtime

  @doc """
  Starts an application under a supervised runtime, given a module implementing
  the `Ratatouille.Application` behaviour. This call blocks until the
  application is quit (or it crashes).

  This is intended as a way to easily run simple apps and examples. For more
  complex apps depending on other processes, it's recommended to define an OTP
  application and start the `Ratatouille.Runtime.Supervisor` as a child of your
  application supervisor.

  ### Example

      defmodule Counter do
        @behaviour Ratatouille.App

        import Ratatouille.View

        def init(_context), do: 0

        def update(model, msg) do
          case msg do
            {:event, %{ch: ?+}} -> model + 1
            {:event, %{ch: ?-}} -> model - 1
            _ -> model
          end
        end

        def render(model) do
          view do
            label(content: "Counter is \#{model} (+/-)")
          end
        end
      end

      Ratatouille.run(Counter)

  """
  def run(application, opts \\ []) do
    runtime_opts = Keyword.merge([app: application], opts)

    {:ok, pid} = Runtime.Supervisor.start_link(runtime: runtime_opts)

    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    end
  end
end
