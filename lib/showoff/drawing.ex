defmodule Showoff.Drawing do
  @enforce_keys [:svg, :text]
  defstruct [:id, :svg, :text, :author]
end
