defmodule StdlibEx.Counter do
  @moduledoc """
  Documentation for `StdlibEx.Counter`
  This module is an elixir interface wrapper around erlang's :counters module
  """

  @spec new(pos_integer, [:atomics | :write_concurrency]) :: :counters.counters_ref()
  def new(size, options \\ [:write_concurrency]) when is_integer(size) and size > 0 do
    :counters.new(size, options)
  end

  @spec info(:counters.counters_ref()) :: %{memory: non_neg_integer, size: non_neg_integer}
  def info(ref) do
    :counters.info(ref)
  end

  @spec add(:counters.counters_ref(), integer, integer) :: :ok
  def add(ref, idx, incr \\ 1) when is_integer(idx) and idx > 0 and is_integer(incr) do
    :counters.add(ref, idx, incr)
  end

  @spec get(:counters.counters_ref(), pos_integer) :: integer
  def get(ref, idx) when is_integer(idx) and idx > 0 do
    :counters.get(ref, idx)
  end

  @spec put(:counters.counters_ref(), pos_integer, integer) :: :ok
  def put(ref, idx, value) when is_integer(idx) and idx > 0 and is_integer(value) do
    :counters.put(ref, idx, value)
  end

  @spec sub(:counters.counters_ref(), pos_integer, integer) :: :ok
  def sub(ref, idx, decr \\ -1) when is_integer(idx) and idx > 0 and is_integer(decr) do
    :counters.sub(ref, idx, decr)
  end
end
