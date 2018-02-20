# ExTermbox

[![Hex.pm](https://img.shields.io/hexpm/v/ex_termbox.svg)](https://hex.pm/packages/ex_termbox)
[![Hexdocs.pm](https://img.shields.io/badge/api-hexdocs-brightgreen.svg)](https://hexdocs.pm/ex_termbox)

Low-level [termbox](https://github.com/nsf/termbox) bindings and a high-level,
functional terminal UI kit for Elixir.

The low-level bindings can already be used; the high-level APIs are still under
active development and subject to change.

For the API Reference, see: [https://hexdocs.pm/ex_termbox](https://hexdocs.pm/ex_termbox).

## Getting Started

TODO - Add examples & screenshots here.

## Installation

During development, it's recommended to try building from source, as the Hex
package tends to lag behind.

### From Hex

Add ExTermbox as a dependency in your project's `mix.exs`:

```elixir
def deps do
  [
    {:ex_termbox, "~> 0.1.0"}
  ]
end
```

The Hex package bundles a compatible version of termbox. There are some compile
hooks to automatically build and link a local copy of `ltermbox` for your
application. This should happen the first time you build ExTermbox (e.g., via
`mix deps.compile`).

So far the build has been tested on macOS and a few Linux distros. Please add
an issue if you encounter any issues.

### From Source

To try out the master branch, first clone the repo:

```bash
git clone --recurse-submodules git@github.com:ndreynolds/ex_termbox.git
cd ex_termbox
```

The `--recurse-submodules` flag (`--recursive` before Git 2.13) is necessary in
order to additionally clone the termbox source code, which is required to
build this project.

Next, fetch the deps:

```
mix deps.get
```

Finally, try out one of the included [`examples/`](examples):

```
mix run examples/rendering.exs > debug.log
```

If you see lots of things drawn on your terminal screen, you're good to go. Use
"q" to quit in the examples.
