# Generates the elements reference table displayed in the README
#
# Usage:
#   mix run scripts/generate_elements_table.exs

IO.puts("| Element | Description |")

for {el, spec} <- Ratatouille.Renderer.Element.specs do
  doc_url = "https://hexdocs.pm/ratatouille/Ratatouille.View.html##{el}/0"
  IO.puts("| [`#{el}`](#{doc_url}) | #{spec[:description]} |")
end
