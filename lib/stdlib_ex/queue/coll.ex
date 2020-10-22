defimpl Collectable, for: StdlibEx.Queue do
  @spec into(StdlibEx.Queue.t()) ::
          {StdlibEx.Queue.t(), (any, :done | :halt | {:cont, any} -> any)}
  def into(%StdlibEx.Queue{} = queue) do
    {queue, &push/2}
  end

  defp push(queue, {:cont, item}), do: StdlibEx.Queue.push(queue, item)
  defp push(queue, :done), do: queue
  defp push(_queue, :halt), do: :ok
end
