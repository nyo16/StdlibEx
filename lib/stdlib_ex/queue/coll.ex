defimpl Collectable, for: StdlibEx.Queue do
  def into(%StdlibEx.Queue{} = queue) do
    {queue, &push/2}
  end

  defp push(queue, {:cont, item}), do: StdlibEx.Queue.push(queue, item)
  defp push(queue, :done), do: queue
  defp push(_queue, :halt), do: :ok
end
