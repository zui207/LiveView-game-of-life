defmodule GameOfLife.Cell do
  defstruct alive: false, position: {0, 0}

  def new(position, bool \\ false) do
    __struct__(position: position, alive: bool)
  end

end
