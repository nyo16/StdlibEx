defimpl Inspect, for: StdlibEx.Counter do
  import Inspect.Algebra

  def inspect(counter, opts) do
    info = :counters.info(counter.ref)
    values = 1..info[:size] |> Enum.map(fn pos -> StdlibEx.Counter.get(counter, pos) end)
    info = Map.put(info, :values, values)
    concat(["#Counter<", to_doc(Enum.to_list(info), opts), ">"])
  end
end
