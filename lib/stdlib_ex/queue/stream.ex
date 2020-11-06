defmodule StdlibEx.Queue.Stream do
  alias StdlibEx.Queue

  def create(%Queue{} = queue, chunk_num \\ 100) do
    Stream.resource(fn -> {queue, chunk_num} end, &iterate/1, fn _ -> :ok end)
  end

  defp iterate({queue, chunk_num}) do
    case Queue.slice(queue, chunk_num) do
      {q1, rest} -> {:queue.to_list(q1.data), {rest, chunk_num}}
      :empty -> {:halt, []}
    end
  end
end
