# TODOs

## Document: Concepts

* Termbox bindings
* Declarative views
* Window server
* Event manager

## Document: How to distribute an ExTermbox app

* Unfortunately an escript won't work because escripts don't support the `priv/`
  directory, which ExTermbox needs to load the termbox so.
* Could potentially use archives, but they're intended for Mix extensions.
* Distillery supports building self-contained executables. This seems like the
  best option right now.
  
## User Input

The event manager is a fairly low-level API for reacting to user input. It's not
clear how to best abstract this. 

While HTML has input elements that can be directly interacted with to change the
state of the view, all the elements in ExTermbox are static. Keeping the
elements static seems to be ideal, as this makes the view itself stateless.
Event handling and state management can happen above the view layer, which
makes applications easier to reason about.

For complicated views, it would be interesting to explore a component-style
architecture, similar to nested React components. Components could receive
props, bind to a subset of events, manage internal state, and render their own
view.

## More Responsive Layouts

ExTermbox already supports resizing elements such as columns when the window
dimensions change.

Web frameworks like Bootstrap allow a column layout to collapse when its columns
would be too narrow to display their content properly (e.g., on a mobile
device). ExTermbox could provide similar functionality by providing a way to
specify the column size at different screen widths.

## Table Elements

Table components should all be separate elements to support fine-grained
styling of content.

```elixir
element(:table, %{}, [
  element(:table_row, %{}, [
    element(:table_cell, %{}, [
      element(:text, %{content: "X"}, [])
    ])
  ])
])
```

However we can support shortcut forms via named functions and/or macros:

```elixir
table do
  table_row(["A", "B", "C"])
  table_row do
    table_cell(@style_blue, "A")
    table_cell("B")
    table_cell do
      text(@style_red, "X")
      text("Y")
      text("Z")
    end
  end
end
```

## Compile-time validation of views

It should be possible to validate the structure of the view tree at
compile-time, which could help us to avoid the cost of validation at runtime.

## Canvas/View Diffing 

The window server stores the current view and provides an API for updating this
view. When the view is updated, the entire terminal is first cleared, the cell
buffer is updated cell by cell, and then the updated cell buffer is presented.

Rendering happens in two phases. First the view tree is rendered to a canvas (a
mapping of coordinates to cells). Then this canvas is rendered to the terminal by
updating the cells at each coordinate pair.

It's definitely possible to optimize this.

We could merge the new canvas and the old canvas and tag the changed cells as
inserts, updates or deletes. Then we perform only the tagged changes. Should
dramatically reduce the number of update operations, particularly for use cases
like a small updating clock.
