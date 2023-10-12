# I never got this working!
defmodule Codebreaker do
  @behaviour Problem
  alias Types.Chromosome

  use Bitwise

  @impl true
  def genotype do
    genes =
      for _ <- 1..64 do
        Enum.random(0..1)
      end

    %Chromosome{genes: genes, size: 64}
  end

  @impl true
  def fitness_function(chromosome) do
    IO.write("??????????????????????????????/")
    target = ~c"ILoveGeneticAlgorithms"
    encrypted = ~c"LIjs`B`k`qlfDibjwlqmhv"

    cipher = fn word, key ->
      IO.inspect(word)
      IO.inspect(key)
      IO.inspect(4_993_825_805_667_487_819 ^^^ key)

      Enum.map(word, rem(&(&1 ^^^ key), 32768))
    end

    key =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?(population, _generation) do
    Enum.max_by(population, &Codebreaker.fitness_function/1).fitness == 1
  end
end

soln = Genetic.run(Codebreaker, crossover_type: &Toolbox.Crossover.single_point/2)

{key, ""} =
  soln.genes
  |> Enum.map(&Integer.to_string(&1))
  |> Enum.join("")
  |> Integer.parse(2)

IO.write("\nThe Key is #{key}\n")
