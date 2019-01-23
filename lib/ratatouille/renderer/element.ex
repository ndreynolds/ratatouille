defmodule Ratatouille.Renderer.Element do
  @moduledoc false

  alias __MODULE__, as: Element

  @type t :: %Element{tag: atom()}

  @enforce_keys [:tag]
  defstruct tag: nil, attributes: %{}, children: []

  ### Element Specs

  @specs [
    view: [
      description: "Top-level container",
      child_tags: [:row, :panel],
      attributes: [
        top_bar: {:optional, "A `:bar` element to occupy the view's first row"},
        bottom_bar:
          {:optional, "A `:bar` element to occupy the view's last row"}
      ]
    ],
    row: [
      description:
        "Container used to define grid layouts with one or more columns",
      child_tags: [:column],
      attributes: []
    ],
    column: [
      description: "Container occupying a vertical segment of the grid",
      child_tags: [:panel, :table, :row, :label, :chart, :sparkline, :tree],
      attributes: [
        size:
          {:required,
           "Number of units on the grid that the column should occupy"}
      ]
    ],
    panel: [
      description:
        "Container with a border and title used to demarcate content",
      child_tags: [:table, :row, :label, :panel, :chart, :sparkline, :tree],
      attributes: [
        height:
          {:optional,
           "Height of the table in rows or `:fill` to fill the parent container's box"},
        title: {:optional, "Binary containing the title for the panel"}
      ]
    ],
    label: [
      description: "Block-level element for displaying text",
      child_tags: [:text],
      attributes: [
        content:
          {:optional, "Binary containing the text content to be displayed"}
      ]
    ],
    text: [
      description: "Inline element for displaying uniformly-styled text",
      child_tags: [],
      attributes: [
        content:
          {:required, "Binary containing the text content to be displayed"},
        color: {:optional, "Constant representing color to use for foreground"},
        background:
          {:optional, "Constant representing color to use for background"},
        attributes:
          {:optional, "Constant representing style attributes to apply"}
      ]
    ],
    bar: [
      description:
        "Block-level element for creating title, status or menu bars",
      child_tags: [:label],
      attributes: []
    ],
    table: [
      description: "Container for displaying data in rows and columns",
      child_tags: [:table_row],
      attributes: []
    ],
    table_row: [
      description: "Container representing a row of the table",
      child_tags: [:table_cell],
      attributes: []
    ],
    table_cell: [
      description: "Element representing a table cell",
      child_tags: [],
      attributes: [
        content: "Binary containing the text content to be displayed"
      ]
    ],
    tree: [
      description: "Container for displaying data as a tree of nodes",
      child_tags: [:tree_node],
      attributes: []
    ],
    tree_node: [
      description: "Container representing a tree node",
      child_tags: [:tree_node],
      attributes: [
        content: {:required, "Binary label for the node"}
      ]
    ],
    sparkline: [
      description: "Element for plotting a series in a single line",
      child_tags: [],
      attributes: [
        series:
          {:required, "List of float or integer values representing the series"}
      ]
    ],
    chart: [
      description: "Element for plotting a series as a multi-line chart",
      child_tags: [],
      attributes: [
        series:
          {:required, "List of float or integer values representing the series"},
        type:
          {:required,
           "Type of chart to plot. Currently only `:line` is supported"},
        height: {:optional, "Height of the chart in rows"}
      ]
    ]
  ]

  def specs, do: @specs
end
