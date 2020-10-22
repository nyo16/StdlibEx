defimpl Enumerable, for: StdlibEx.Queue do
  def count(%StdlibEx.Queue{queue: queue}), do: {:ok, :queue.len(queue)}

  def member?(%StdlibEx.Queue{queue: queue}, item) do
    {:ok, :queue.member(item, queue)}
  end

  def reduce(%StdlibEx.Queue{queue: queue}, acc, fun) do
    Enumerable.List.reduce(:queue.to_list(queue), acc, fun)
  end

  def slice(%StdlibEx.Queue{}), do: {:error, __MODULE__}
end
