defmodule Types.Chromosome do
  # ch 11 using Agents to optimize
  # use Agent

  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: number(),
          age: integer()
        }

  @enforce_keys :genes
  defstruct [
    :genes,
    id: Base.encode16(:crypto.strong_rand_bytes(64)),
    size: 0,
    fitness: 0,
    age: 0
  ]

  # ch 11 using Agents to optimize
  # def start_link(genes) do
  #   Agent.start_link(fn -> %Chromosome{genes: genes, size: Enum.count(genes)} end)
  # end
  #
  # def get_fitness(pid) do
  #   Agent.get(pid, & &1.fitness)
  # end
  #
  # def eval(pid, fitness) do
  #   c = Agent.get(pid, & &1)
  #   Agent.update(pid, fn -> %Chromosome{c | fitness: fitness.(c)} end)
  # end
end
