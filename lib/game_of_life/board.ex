defmodule GameOfLife.Board do

  @height 13
  @width  21

  alias GameOfLife.{Cell, Cells}

  def board(height, width) do
    for h <- 1..height, w <- 1..width, do: {w, h}
  end

  def new() do
    board(@height, @width)
    |> Enum.reduce(%{}, fn coord, acc ->
      Map.put(acc, coord, Cells.new(coord))
    end)
  end

  def set(board, points \\ [], bool \\ true) do
    points
    |> Enum.reduce(board, fn coord, acc ->
        new_cells = %{get_in(acc, [coord]) | cell: Cell.new(coord, bool)}
        %{acc | coord => new_cells}
       end)
    |> Enum.reduce(board, fn {coord, cells}, acc ->
        new_cells = get_in(count(board, cells), [coord])
        %{acc | coord => new_cells}
       end)
  end

  def count(board, %{cell: %{position: position}, neibours: neibours}=cells) do
    count =
      neibours
      |> Enum.reduce(0, fn %{position: coord}, acc ->
        bool =
          case get_in(board, [coord]) do
            nil   -> false
            cells -> get_in(cells, [Access.key(:cell), Access.key(:alive)])
          end

        if bool, do: acc+1, else: acc
      end)

    new_cells = %{cells | live_count: count}
    %{board | position => new_cells}
  end

  def check(board) do
    board
    |> Enum.reduce(%{}, fn {coord, cells}, acc ->
      Map.put(acc, coord, Cells.check(cells))
    end)
  end

  def update(board, cells) do
    board
    |> count(cells)
    |> check()
  end

  def status(board, point) do
    %{^point => cells} = board
    Cells.status(cells)
  end

  def alive?(board) do
    board
    |> Map.values()
    |> Enum.any?(&Cells.status/1)
  end

end
