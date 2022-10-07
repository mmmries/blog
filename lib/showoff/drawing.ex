defmodule Showoff.Drawing do
  @enforce_keys [:svg, :text, :author]
  defstruct [:id, :svg, :text, :author]
end
