defmodule TetrisInterface do
  use Agent

  def start_link(path_to_tetris_rom) do
    int = Alex.new()

    game =
      int
      |> Alex.set_option(:display_screen, true)
      |> Alex.set_option(:sound, true)
      |> Alex.set_option(:random_seed, 123)
      |> Alex.load(path_to_tetris_rom)

    Agent.start_link(fn -> game end, name: __MODULE__)
  end
end

defmodule Tetris do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    # get the ALE
    game = Agent.get(TetrisInterface, & &1)
    genes = for _ <- 1..1000, do: Enum.random(game.legal_actions)
    %Chromosome{genes: genes, size: 1000}
  end

  @impl true
  def terminate?(population, generation) do
    generation == 5
  end

  @impl true
  def fitness_function(chromosome) do
    # get the ALE
    game = Agent.get(TetrisInterface, & &1)
    actions = chromosome.genes

    game =
      actions
      |> Enum.reduce(game, fn act, game -> Alex.step(game, act) end)

    reward = game.reward
    # Reset the game after a run
    Alex.reset_game(game)
    reward
  end
end

TetrisInterface.start_link("deps/alex/priv/tetris.bin")

soln = Genetic.run(Tetris, population_size: 10)

IO.write("\n")
IO.inspect("Best is #{soln}\n")
