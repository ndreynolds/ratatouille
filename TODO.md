# TODOs

## Known Rendering Bugs / Omissions

* Can't pass attributes / color to table cells.

## More Responsive Layouts

ExTermbox already supports resizing elements such as columns when the window
dimensions change.

Web frameworks like Bootstrap allow a column layout to collapse when its columns
would be too narrow to display their content properly (e.g., on a mobile
device). ExTermbox could provide similar functionality by providing a way to
specify the column size at different screen widths.

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
