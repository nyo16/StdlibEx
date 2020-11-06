defmodule StdlibEx.Counter do
  @moduledoc """
  Documentation for `StdlibEx.Counter`
  This module is an elixir interface wrapper around erlang's :counters module
  """

  defstruct ref: nil, size: 1, key_mapping: %{}

  @opaque t(type) :: %__MODULE__{:ref => :counters.counters(type)}
  @opaque t() :: %__MODULE__{:ref => :counters.counters()}

  @spec new(pos_integer, [:atomics | :write_concurrency]) :: StdlibEx.Counter.t()
  def new(size, options \\ [:write_concurrency]) when is_integer(size) and size > 0 do
    %__MODULE__{ref: :counters.new(size, options), size: size}
  end

  @spec info(StdlibEx.Counter.t()) :: %{memory: non_neg_integer, size: non_neg_integer}
  def info(%__MODULE__{ref: ref, size: _size}) do
    :counters.info(ref)
  end

  @spec add(StdlibEx.Counter.t(), pos_integer, integer) :: :ok
  def add(%__MODULE__{ref: ref, size: size}, idx, incr \\ 1)
      when is_integer(idx) and idx > 0 and is_integer(incr) and idx <= size do
    :counters.add(ref, idx, incr)
  end

  @spec get(StdlibEx.Counter.t(), pos_integer) :: integer
  def get(%__MODULE__{ref: ref, size: size}, idx)
      when is_integer(idx) and idx > 0 and idx <= size + 1 do
    :counters.get(ref, idx)
  end

  @spec put(StdlibEx.Counter.t(), pos_integer, integer) :: :ok
  def put(%__MODULE__{ref: ref, size: size}, idx, value)
      when is_integer(idx) and idx > 0 and is_integer(value) and idx <= size do
    :counters.put(ref, idx, value)
  end

  @spec sub(StdlibEx.Counter.t(), pos_integer, integer) :: :ok
  def sub(%__MODULE__{ref: ref, size: size}, idx, decr \\ -1)
      when is_integer(idx) and idx > 0 and is_integer(decr) and idx <= size do
    :counters.sub(ref, idx, decr)
  end
end
