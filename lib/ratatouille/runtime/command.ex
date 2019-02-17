defmodule Ratatouille.Runtime.Command do
  @moduledoc """
  Commands provide a way to start an expensive call in the background and get
  the result back via `c:Ratatouille.App.update/2`.

  Commands should be constructed via the functions below and not via the struct
  directly, as this is internal and subject to change.
  """

  alias __MODULE__

  @enforce_keys [:type]
  defstruct [:type, :message, :function, :subcommands]

  @doc """
  Returns a new command that can be returned in the `c:Ratatouille.App.update/2`
  or `c:Ratatouille.App.init/1` callbacks.

  Takes an anonymous function and a message. The message is used to send a
  response back to your app along with the result. It can be any Erlang term, so
  it's also possible to include identifiers (e.g., `{:finished, id}`).
  """
  @spec new((-> term()), term()) :: Command.t()
  def new(func, message) when is_function(func) do
    %Command{type: :single, message: message, function: func}
  end

  # TODO: Need an MFA-style form of new/2

  @doc """
  Returns a batch command given a list of commands. This simply provides a way
  to return multiple commands as a single one. Batch commands should not depend
  on one another---Ratatouille's runtime may run some or all of them in
  parallel and doesn't guarantee any particular order of execution.

  Dependencies should be expressed via a single command or a sequence of
  commands orchestrated via the application model state.
  """
  @spec batch([Command.t()]) :: Command.t()
  def batch([%Command{} | _] = cmds) do
    %Command{type: :batch, subcommands: cmds}
  end

  @doc false
  def to_list(%Command{type: :batch, subcommands: [cmd | rest]}) do
    to_list(cmd) ++ to_list(%Command{type: :batch, subcommands: rest})
  end

  def to_list(%Command{type: :batch, subcommands: []}), do: []

  def to_list(%Command{type: :single} = cmd), do: [cmd]
end
