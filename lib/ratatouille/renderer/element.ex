defmodule Ratatouille.Renderer.Element do
  @moduledoc false

  alias __MODULE__, as: Element

  alias Ratatouille.Renderer.Element.{
    Bar,
    Canvas,
    Chart,
    Column,
    Label,
    Overlay,
    Panel,
    ProgressBar,
    Row,
    Sparkline,
    Table,
    Tree,
    View,
    Viewport
  }

  @type t :: %Element{tag: atom()}

  @enforce_keys [:tag]
  defstruct tag: nil, attributes: %{}, children: []

  @content_tags [
    :canvas,
    :chart,
    :label,
    :panel,
    :row,
    :sparkline,
    :table,
    :tree,
    :viewport,
    :progress_bar
  ]

  ### Element Specs

  @specs [
    bar: [
      description:
        "Block-level element for creating title, status or menu bars",
      renderer: Bar,
      child_tags: [:label],
      attributes: []
    ],
    canvas: [
      description: "A free-form canvas for drawing arbitrary shapes",
      renderer: Canvas,
      child_tags: [:canvas_cell],
      attributes: [
        height: {:required, "Integer representing the canvas height"},
        width: {:required, "Integer representing the canvas width"}
      ]
    ],
    canvas_cell: [
      description: "A canvas cell which represents one square of the canvas",
      child_tags: [],
      attributes: [
        x: {:required, "Integer representing the cell's column (zero-indexed)"},
        y: {:required, "Integer representing the cell's row (zero-indexed)"},
        color: {:optional, "Constant representing color to use for foreground"},
        char: {:optional, "Single character to render within this cell"},
        background:
          {:optional, "Constant representing color to use for background"},
        attributes:
          {:optional, "Constant representing style attributes to apply"}
      ]
    ],
    chart: [
      description: "Element for plotting a series as a multi-line chart",
      renderer: Chart,
      child_tags: [],
      attributes: [
        series:
          {:required, "List of float or integer values representing the series"},
        type:
          {:required,
           "Type of chart to plot. Currently only `:line` is supported"},
        height: {:optional, "Height of the chart in rows"}
      ]
    ],
    column: [
      description: "Container occupying a vertical segment of the grid",
      renderer: Column,
      child_tags: @content_tags,
      attributes: [
        size:
          {:required,
           "Number of units on the grid that the column should occupy"}
      ]
    ],
    label: [
      description: "Block-level element for displaying text",
      renderer: Label,
      child_tags: [:text],
      attributes: [
        content:
          {:optional, "Binary containing the text content to be displayed"},
        color: {:optional, "Constant representing color to use for foreground"},
        background:
          {:optional, "Constant representing color to use for background"},
        attributes:
          {:optional, "Constant representing style attributes to apply"},
        wrap:
          {:optional,
           "Boolean indicating whether or not to wrap lines to fit available space"}
      ]
    ],
    overlay: [
      description: "Container overlaid on top of the view",
      renderer: Overlay,
      child_tags: @content_tags,
      attributes: [
        padding: {:optional, "Integer number of units of padding"}
      ]
    ],
    panel: [
      description:
        "Container with a border and title used to demarcate content",
      renderer: Panel,
      child_tags: @content_tags,
      attributes: [
        color: {:optional, "Color of title"},
        background: {:optional, "Background of title"},
        attributes: {:optional, "Attributes for the title"},
        padding:
          {:optional,
           "Integer providing inner padding to use when rendering child elements"},
        height:
          {:optional,
           "Height of the table in rows or `:fill` to fill the parent container's box"},
        title: {:optional, "Binary containing the title for the panel"}
      ]
    ],
    progress_bar: [
      description: "Inline element for displaying a progress bar",
      renderer: ProgressBar,
      child_tags: [],
      attributes: [
        percentage: {:required, "The actual percentage"},
        text_position:
          {:optional,
           "Where to put the text showing the percentage, `:none`, `:left` or `:right`. Defaults to `:right`"},
        on_color: {:optional, "The main color of the bar"},
        off_color: {:optional, "The background color of the bar"},
        text_color: {:optional, "The color of the percentage text"}
      ]
    ],
    row: [
      description:
        "Container used to define grid layouts with one or more columns",
      renderer: Row,
      child_tags: [:column],
      attributes: []
    ],
    sparkline: [
      description: "Element for plotting a series in a single line",
      renderer: Sparkline,
      child_tags: [],
      attributes: [
        series:
          {:required, "List of float or integer values representing the series"}
      ]
    ],
    table: [
      description: "Container for displaying data in rows and columns",
      renderer: Table,
      child_tags: [:table_row],
      attributes: []
    ],
    table_cell: [
      description: "Element representing a table cell",
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
    table_row: [
      description: "Container representing a row of the table",
      child_tags: [:table_cell],
      attributes: [
        color: {:optional, "Constant representing color to use for foreground"},
        background:
          {:optional, "Constant representing color to use for background"},
        attributes:
          {:optional, "Constant representing style attributes to apply"}
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
    tree: [
      description: "Container for displaying data as a tree of nodes",
      renderer: Tree,
      child_tags: [:tree_node],
      attributes: []
    ],
    tree_node: [
      description: "Container representing a tree node",
      child_tags: [:tree_node],
      attributes: [
        content: {:required, "Binary label for the node"},
        color: {:optional, "Constant representing color to use for foreground"},
        background:
          {:optional, "Constant representing color to use for background"},
        attributes:
          {:optional, "Constant representing style attributes to apply"}
      ]
    ],
    view: [
      description: "Top-level container",
      renderer: View,
      child_tags: [:overlay | @content_tags],
      attributes: [
        top_bar: {:optional, "A `:bar` element to occupy the view's first row"},
        bottom_bar:
          {:optional, "A `:bar` element to occupy the view's last row"}
      ]
    ],
    viewport: [
      description: "Container for offsetting content (e.g., for scrolling)",
      renderer: Viewport,
      child_tags: @content_tags,
      attributes: [
        offset_x:
          {:optional,
           "Integer representing the number of columns to offset the child content by. Defaults to 0."},
        offset_y:
          {:optional,
           "Integer representing the number of rows to offset the child content by. Defaults to 0."}
      ]
    ]
  ]

  def specs, do: @specs
end
