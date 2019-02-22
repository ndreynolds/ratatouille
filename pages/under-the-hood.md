# Under the Hood

Ratatouille's runtime wraps up most of the logic concerning the application
loop, update the terminal window, and subscribing to and delegating events.
It's convenient to let the runtime worry about these details, and it allows us
to write apps more declaratively by defining them in terms of
callbacks---similar to how we implement OTP behaviours like gen_server and
supervisor.

In some cases, it may be necessary to control these details. This guide
explains how you can use the window, event manager, `receive` and some
recursion to manually define an application loop.

## Hello World from Scratch

Let's build a hello world application. It'll display "Hello World" and quit when
the "q" key is pressed. First we'll look at the entire example, then we'll go
through it line by line to see what each line does. You can also find this
example [in the repo][hello_world_example] and run it with `mix run`.

[hello_world_example]: https://github.com/ndreynolds/ratatouille/blob/master/examples/without-runtime/hello_world.exs

```elixir
# examples/hello_world.exs

alias Ratatouille.{EventManager, Window}

import Ratatouille.View

{:ok, _pid} = Window.start_link()
{:ok, _pid} = EventManager.start_link()
:ok = EventManager.subscribe(self())

hello_world_view =
  view do
    panel title: "Hello, World!", height: :fill do
      label(content: "Press 'q' to quit.")
    end
  end

:ok = Window.update(hello_world_view)

receive do
  {:event, %{ch: ?q}} ->
    :ok = Window.close()
end
```

First, some aliases for the modules we'll use:

```elixir
alias Ratatouille.{EventManager, Window}
```

Next, we import the View DSL from
[`Ratatouille.View`](https://hexdocs.pm/ratatouille/Ratatouille.View):

```elixir
import Ratatouille.View
```

The View DSL provides element builder functions like `view`, `row`, `table`,
`label` that you can use to define views. Think of them like HTML tags.

Now we'll initialize the application using `Ratatouille.Window`. This is a
gen_server that manages our terminal window and exposes a basic API for
accessing information about or updating the terminal window. On init, it draws a
blank canvas over the terminal:

```elixir
{:ok, _pid} = Window.start_link()
```

In a real project, you'll usually want to use an OTP application with a proper
supervision tree, but here we'll keep it as simple as possible and start our
processes manually.

In order to react to keyboard, click or resize events, we'll use
`Ratatouille.EventManager`. The event manager allows processes to subscribe to
events and then send its subscribers a message whenever an event is triggered.
We need to start the event manager and subscribe the current process to any
events:

```elixir
{:ok, _pid} = EventManager.start_link()
:ok = EventManager.subscribe(self())
```

Next, we define a view. Similar to HTML, a view is defined as a tree of nodes.
Nodes have attributes (e.g., text: bold) and children (nested content). Every
view must start with a root `view` element---it's sort of like the `<body>` tag
in HTML.

```elixir
hello_world_view =
  view do
    panel title: "Hello, World!", height: :fill do
      label(content: "Press 'q' to quit.")
    end
  end
```

Defining a view only does just that. To render it to the screen, we need to call
the `Window.update/1` function, passing our view as the argument.

```elixir
:ok = Window.update(hello_world_view)
```

When a key is pressed, it'll be sent to us by the event manager. Once we receive
a 'q' key press, we'll close the application. Here, we use the built-in
`receive` function with pattern-matching in order to match only the 'q' key
press event:

```elixir
receive do
  {:event, %{ch: ?q}} ->
    :ok = Window.close()
end
```

That's it---now you can run the program with `mix run <file>`. To run the
bundled example:

```bash
$ mix run examples/hello_world.exs
```

You should see the content we created and be able to quit using 'q'.


## Application Loops

While the previous example illustrated the basics, it's unfortunately not a very
useful application on its own. Useful terminal applications need to update the
view based on events or on a given interval (e.g., every second). They may also
need to hold state such as the cursor position or selected tab, and fetch data
from local sources or via the network.

### Rendering on an interval

This time we'll build a clock application to show how intervals can be achieved.
It will display the current time and update each second.

Be careful trying this one out, as we don't provide a way to quit yet---you'll
need to kill the process (for example, by closing your terminal window).

```elixir
defmodule Clock do
  alias Ratatouille.Window

  import Ratatouille.View

  def start do
    {:ok, _pid} = Window.start_link()
    loop()
  end

  def loop do
    clock_view = render(DateTime.utc_now())
    Window.update(clock_view)
    Process.sleep(1_000)
    loop()
  end

  def render(now) do
    view do
      panel title: "Clock Example" do
        label(content: "The time is: " <> DateTime.to_string(now))
      end
    end
  end
end

Clock.start()
```

There are a few things of note here.

We've defined this application in a module. This is how you'll usually want to
do it.

We've defined a `start/1` function to do the initial setup.

That setup calls the `loop/0` function, which is our application loop. Each loop
renders a view, updates the window, waits one second and then calls itself to
start the process all over again.

The view is built via a `render/1` function. If you're familiar with React.js,
the idea is similar. Our "render" functions should always be pure functions of
their state--any two calls with the same arguments should always have the same
result. As such, we also pass in the state here: the current time.

Lastly, we remember to actually start this thing with `Clock.start()`.

### Combining an interval with event handling

In the clock example, we now have a working update interval, but no way to
handle events---and therefore, no way to quit the application. Let's fix that:

```elixir
defmodule Clock do
  alias Ratatouille.{EventManager, Window}

  import Ratatouille.View

  def start do
    {:ok, _pid} = Window.start_link()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())
    loop()
  end

  def loop do
    clock_view = render(DateTime.utc_now())
    Window.update(clock_view)

    receive do
      {:event, %{ch: ?q}} ->
        :ok = Window.close()
    after
      1_000 ->
        loop()
    end
  end

  def render(now) do
    view do
      panel title: "Clock Example ('q' to quit)" do
        label(content: "The time is: " <> DateTime.to_string(now))
      end
    end
  end
end

Clock.start()
```

In the new version, we fire up the event manager and subscribe ourself to
any events that come through.

Then we use a `receive` like in the hello world application, and pair that with
an `after` to achieve the interval.

Instead of sleeping, our loop now has a new job: wait for events for 1 second,
then start over (updating and re-rendering the clock).

Try it out yourself:

```bash
mix run examples/clock.exs
```

### Holding on to state

In the clock example, we were working with externally defined state that we
retrieved in each loop with some help from Elixir and the BEAM.

But what if we need to hold on to state across loops?

As a concrete example, imagine we want to hold on to the cursor position. Maybe
this is a text editor. This is possible by storing our state within the
application loop itself (not unlike how a gen_server works under the hood):

```elixir
def start do
  # ...

  loop(0) # initial cursor
end

def loop(cursor) do
  # ...

  receive do
    {:event, %{ch: @arrow_down}} ->
      loop(cursor + 1)

    {:event, %{ch: @arrow_up}} ->
      loop(cursor - 1)
  after
    1_000 ->
      loop(cursor)
  end
end
```

