defmodule StdlibEx.DiskLog.Stream do
  alias StdlibEx.DiskLog

  def create(%DiskLog{} = log) do
    Stream.resource(fn -> log end, &iterate/1, fn _ -> :ok end)
  end

  defp iterate(%DiskLog{} = log) do
    case DiskLog.read_chunk(log) do
      :eof -> {:halt, []}
      {maybe_next, results} -> {results, {maybe_next, log}}
    end
  end

  defp iterate({maybe_next, log}) do
    case DiskLog.read_chunk(log, maybe_next) do
      :eof -> {:halt, []}
      {maybe_next, results} -> {results, {maybe_next, log}}
    end
  end
end
