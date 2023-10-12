defmodule Toolbox.Reinsertion do
  @doc """
  This is the most straightforward strategy, it's also
  referred to a "generational replacement".
  """
  def pure(_parents, offspring, _leftovers), do: offspring

  @doc """
  elitist keeps the best parents in the next generation. A survival rate
  of 0.20 is a good default
  """
  def elitist(parents, offspring, leftovers, survival_rate) do
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)

    survivors =
      old
      |> Enum.sort_by(& &1.fitness, :desc)
      |> Enum.take(n)

    offspring ++ survivors
  end

  @doc """
  This is essentially a random reinsertion of parents into the 
  next generation. It isn't very common.
  """
  def uniform(parents, offspring, leftovers, survival_rate) do
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)

    survivors =
      old
      |> Enum.take_random(n)

    offspring ++ survivors
  end
end
