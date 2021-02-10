defmodule GameOfLifeWeb.GameLive do
  use GameOfLifeWeb, :live_view

  alias GameOfLife.{Board, Game, Pattern}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(500, :tick)
    end

    {:ok, new_game(socket)}
  end

  def render(assigns) do
    ~L"""
    <div>
      <svg width="840" height="520">
        <%= render_points(assigns) %>
      </svg>
      <button phx-click="start">start</button>
      <button phx-click="stop">stop</button>
      <button phx-click="next">next</button>
      <button phx-click="reset">reset</button>
      <button phx-click="galaxy">galaxy</button>
      generation: <%= inspect @game.generation %>
    </div>
    """
  end

  defp render_points(assigns) do
    ~L"""
    <%= for {{x, y}, %{cell: %{alive: alive}}} <- @game.board do %>
      <rect
        phx-click="point"
        width="40" height="40"
        x="<%= (x-1)*40 %>" y="<%= (y-1)*40 %>"
        style="
          stroke:rgb(0,0,0);
          <%= if alive do %>
            fill:rgb(0,0,0);
          <% else %>
            fill:rgb(255,255,255);
          <% end %>
        "
      />
    <% end %>
    """
  end

  def new_game(socket) do
    assign(socket, game: Game.new(), status: :stop, points: [])
  end

  def next(%{assigns: %{game: %{board: board}}}=socket) do
    if Board.alive?(board) do
      update(socket, :game, &Game.next/1)
    else
      assign(socket, status: :stop)
    end
  end

  def set(%{assigns: %{game: %{board: board}=game}}=socket, x, y) do
    point = {div(x, 40)+1, div(y, 40)+1}
    status = Board.status(board, point)
    new_game = Game.set(game, [point], !status)
    assign(socket, game: new_game)
  end

  def handle_event("start", _, %{assigns: %{status: :ok}}=socket) do
    {:noreply, socket}
  end
  def handle_event("start", _, socket) do
    {:noreply, assign(socket, status: :ok)}
  end

  def handle_event("stop", _, %{assigns: %{status: :stop}}=socket) do
    {:noreply, socket}
  end
  def handle_event("stop", _, socket) do
    {:noreply, assign(socket, status: :stop)}
  end

  def handle_event("next", _, socket) do
    {:noreply, next(socket)}
  end

  def handle_event("reset", _, socket) do
    {:noreply, new_game(socket)}
  end

  def handle_event("galaxy", _, %{assigns: %{game: game}}=socket) do
    pattern = Pattern.galaxy()
    game = Game.set(game, pattern, true)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("point", %{"offsetX" => x, "offsetY" => y}, socket) do
    {:noreply, set(socket, x, y)}
  end

  def handle_info(:tick, %{assigns: %{status: :ok}}=socket) do
    {:noreply, next(socket)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

end
