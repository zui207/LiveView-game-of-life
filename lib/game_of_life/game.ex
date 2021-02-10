defmodule GameOfLife.Game do
  defstruct generation: 0, board: %{}

  alias GameOfLife.Board

  def new() do
    __struct__(board: Board.new())
  end

  def set(%{board: board}=game, points, bool) do
    new_board = Board.set(board, points, bool)
    %{game | board: new_board}
  end

  def next(%{generation: generation, board: board}=game) do
    updated =
      board
      |> Enum.reduce(board, fn {coord, cells}, acc ->
        cells = get_in(Board.update(board, cells), [coord])
        %{acc | coord => cells}
      end)

    %{game | generation: generation+1, board: updated}
  end

end
