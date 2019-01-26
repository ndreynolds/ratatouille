defmodule Ratatouille.App do
  @moduledoc """
  Defines the `Ratatouille.App` behaviour. It provides the structure for
  architecting both large and small terminal applications. This structure
  allows you to render views and update them over time or in response to user
  input.

  ## A Simple Example

      defmodule Counter.App do
        @behaviour Ratatouille.App

        def model(_context), do: 0

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

  ## Architecture

  You may have recognized this pattern from [the Elm Architecture][1]. That's because
  `Ratatouille.App` is just a close translation of this architecture to Elixir.
  Because Elixir and Elm are both functional programming languages, the pattern
  also works very well in Elixir. It helps to centralize state,

  The architecture cleanly separates logic into the following three parts:

  * **Model:** the state of your application
  * **Update:** a way to update your state
  * **View:** a way to view your state as a `%Ratatouille.Element{}` tree (think
    HTML).

  The behaviour callbacks map to these three parts:

  * `c:model/1` defines your initial model, using provided context if needed.
  * `c:update/2` handles a message and retuns a new model.
  * `c:render/1` receives a model and builds a view (an element tree) to view it.

  See the documentation for each callback below for additional details.

  ## Runtime

  As long as you implement the behaviour callbacks, Ratatouille can handle the
  rest. It provides a runtime (`Ratatouille.Runtime`), which will handle
  actually running your application. That means setting up the window, rendering
  the view, subscribing to events and passing these on to the application's
  `update/2` callback, and making sure the view is always re-rendered when the
  application's model changes.

  [1]: https://guide.elm-lang.org/architecture/
  """

  alias Ratatouille.Renderer.Element

  @type context :: map()
  @type model :: term
  @type msg :: term

  @doc """
  The `model/1` callback defines the initial model. This model can be defined
  based on the runtime context. See the "Runtime Context" section under
  `Ratatouille.Runtime` for details on what context is provided.
  """
  @callback model(context) :: model

  @doc """
  The `update/2` callback defines how to update the model in reaction to a
  message (for example, an event or a tick).

  The following messages are currently passed to `update/2` by the runtime:

  * `{:event, event}` - A keyboard or click event.
  * `{:refresh, event}` - A resize event.
  * `:tick` - A tick of the clock. Ticks are sent right before the first render
    and then on the runtime's configured interval afterwards. The first tick can
    be used to do any initial setup.

  The callback should always return the model. It can be the same model or an
  updated one. If the model changes, the runtime will know to re-render the
  model and update the window.
  """
  @callback update(model, msg) :: model

  @doc """
  The `render/1` callback defines how to render the model as a view.

  It should return a `%Ratatouille.Element{}` with the `:view` tag. For example:

      def render(model) do
        view do
          label(content: "Hello, \#{model.name}!")
        end
      end

  """
  @callback render(model) :: Element.t()
end
