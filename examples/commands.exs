# This is an example of how to use commands to perform expensive work in the
# background and receive the results via `update/2`.
#
# Run this example with:
#
#   mix run examples/commands.exs

defmodule Commands do
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Command

  import Ratatouille.View

  def init(_context), do: %{commands: %{}, next_id: 1}

  def update(%{commands: commands, next_id: id} = model, msg) do
    case msg do
      {:event, %{ch: ?t}} ->
        new_model = %{
          model
          | commands: Map.put(commands, id, {:processing, nil}),
            next_id: id + 1
        }

        {new_model, Command.new(&process/0, {id, :finished})}

      {{id, :finished}, result} ->
        %{model | commands: Map.put(commands, id, {:finished, result})}

      _ ->
        model
    end
  end

  defp process do
    # We'll pretend like this is a very expensive call.
    Process.sleep(3_000)
    Enum.random(1..10_000)
  end

  def render(%{commands: commands}) do
    view do
      panel(title: "Press 't' repeatedly to start asynchronous commands") do
        table do
          table_row do
            table_cell(content: "Command ID")
            table_cell(content: "Status")
            table_cell(content: "Result")
          end

          for {id, {status, result}} <- commands do
            table_row do
              table_cell(content: to_string(id))
              table_cell(content: to_string(status))
              table_cell(content: to_string(result))
            end
          end
        end
      end
    end
  end
end

Ratatouille.run(Commands)
