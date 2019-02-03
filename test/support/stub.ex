defmodule Ratatouille.Stub do
  @moduledoc """
  Provides functionality for creating modules that keep a history of calls to
  their functions. The module implements an `Agent` and call history is stored
  with the agent.

  Used in Ratatouille to stub interactions with the termbox bindings.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      use Agent

      import Ratatouille.Stub

      def start_link(_) do
        Agent.start_link(fn -> [] end, name: __MODULE__)
      end

      def calls do
        Agent.get(__MODULE__, & &1)
      end

      def track(call) do
        Agent.update(__MODULE__, fn calls -> [call | calls] end)
      end
    end
  end

  @doc false
  defmacro deftracked(head, body) do
    {name, context, args} = head

    renamed_args = rename_underscored_args(args)
    new_head = {name, context, renamed_args}

    tracking_arg =
      case renamed_args do
        [] ->
          quote do
            unquote(name)
          end

        [a] ->
          quote do
            {unquote(name), unquote(a)}
          end

        [a, b] ->
          quote do
            {unquote(name), unquote(a), unquote(b)}
          end
      end

    quote do
      def unquote(new_head) do
        track(unquote(tracking_arg))
        unquote(body[:do])
      end
    end
  end

  defp rename_underscored_args(args) do
    args
    |> List.wrap()
    |> Enum.with_index()
    |> Enum.map(fn
      {{:_, b, c}, idx} -> {:"arg_#{idx}", b, c}
      {other, _} -> other
    end)
  end
end
