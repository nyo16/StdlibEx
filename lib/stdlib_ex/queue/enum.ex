defimpl Enumerable, for: StdlibEx.Queue do
  def count(%StdlibEx.Queue{length: length}), do: {:ok, length}

  def member?(%StdlibEx.Queue{} = queue, item) do
    {:ok, StdlibEx.Queue.member?(queue, item)}
  end

  def reduce(%StdlibEx.Queue{data: queue}, acc, fun) do
    Enumerable.List.reduce(:queue.to_list(queue), acc, fun)
  end

  def map(%StdlibEx.Queue{data: queue}, fun) do
    Enum.map(:queue.to_list(queue), fun)
  end

  def slice(%StdlibEx.Queue{}), do: {:error, __MODULE__}
end
