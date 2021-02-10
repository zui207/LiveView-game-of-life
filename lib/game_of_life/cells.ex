defmodule GameOfLife.Cells do
  defstruct cell: %{}, neibours: [], live_count: 0

  alias GameOfLife.Cell

  @offsets [{-1,-1},{0,-1},{1,-1},
            {-1,0},        {1,0},
            {-1,1}, {0,1}, {1,1}]

  def init(coord) do
    __struct__(cell: Cell.new(coord))
  end

  def neibours(%{cell: %{position: {x, y}}}=cells) do
    neibours =
      @offsets
      |> Enum.reduce([], fn {dx, dy}, acc ->
        cell = Cell.new({x+dx,y+dy})
        [cell | acc]
      end)

    %{cells | neibours: neibours}
  end

  def new(coord) do
    coord
    |> init()
    |> neibours()
  end

  def update(%{neibours: neibours}=cells, %{position: position}=cell) do
    updated =
      neibours
      |> Enum.map(fn %{position: n_position}=n_cell ->
        if n_position==position, do: cell, else: n_cell
      end)

    %{cells | neibours: updated}
  end

  def check(%{cell: cell}=cells) do
    bool = alive?(cells)
    %{cells | cell: %{cell | alive: bool}}
  end

  def status(%{cell: %{alive: alive}}), do: alive

  defp alive?(%{cell: %{alive: true}, live_count: count}) do
    case count do
      2 -> true
      3 -> true
      _ -> false
    end
  end
  defp alive?(%{cell: %{alive: false}, live_count: count}) do
    case count do
      3 -> true
      _ -> false
    end
  end
end
