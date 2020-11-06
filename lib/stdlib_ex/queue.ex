defmodule StdlibEx.Queue do
  @moduledoc """
  This modules is a wrapper around erlang's queue module plus you can now have length and membership as O(1) and not O(n) (almost)
  """

  alias __MODULE__

  @type t() :: %Queue{}

  defstruct data: :queue.new(), length: 0, bloom_filter: nil

  @doc """
  Creates a new queue (empty)
  """
  @spec new :: StdlibEx.Queue.t()
  def new(), do: %Queue{}

  def new(list) when is_list(list) do
    %Queue{data: :queue.from_list(list), length: length(list)}
  end

  @doc """
  Creates a new queue from a generator/range or list
  """
  @spec new([any] | Range.t()) :: StdlibEx.Queue.t()
  def new(from..n) when is_integer(from) and is_integer(n) do
    list = Enum.to_list(from..n)
    new(list)
  end

  @doc """
  Dont use this yet
  """
  def new_with_bloom() do
    %Queue{bloom_filter: Bloomex.scalable(1000, 0.1, 0.1, 2)}
  end

  def new_with_bloom(list) when is_list(list) do
    bf =
      Enum.reduce(list, Bloomex.scalable(1_000, 0.1, 0.1, 2), fn x, bf ->
        Bloomex.add(bf, x)
      end)

    %Queue{
      data: :queue.from_list(list),
      length: length(list),
      bloom_filter: bf
    }
  end

  def new_with_bloom(from..n) when is_integer(from) and is_integer(n) do
    new_with_bloom(Enum.to_list(from..n))
  end

  @doc """
  Appends a new element to the end of the queue
  """
  @spec append(StdlibEx.Queue.t(), any) :: StdlibEx.Queue.t()
  def append(%Queue{} = queue, term) do
    %Queue{queue | data: :queue.in(term, queue.data), length: queue.length + 1}
  end

  @doc """
  Prepend a new element to head/front of the queue
  """
  @spec prepend(StdlibEx.Queue.t(), any) :: StdlibEx.Queue.t()
  def prepend(%Queue{} = queue, term) do
    %Queue{queue | data: :queue.in_r(term, queue.data), length: queue.length + 1}
  end

  @doc """
  Removes and returns the element and a new queue from the head/front of the queue.
  """
  @spec pop(StdlibEx.Queue.t()) :: {nil, :queue.queue(any)} | {term, StdlibEx.Queue.t()}
  def pop(%Queue{} = queue) do
    case :queue.out(queue.data) do
      {:empty, empty_queue} ->
        {nil, empty_queue}

      {{:value, val}, new_queue} ->
        {val, %Queue{queue | data: new_queue, length: queue.length - 1}}
    end
  end

  @doc """
  Removes and returns the element and a new queue from the beginning of the queue.
  """
  @spec pop_last(StdlibEx.Queue.t()) :: {nil, :queue.queue(any)} | {term, StdlibEx.Queue.t()}
  def pop_last(%Queue{} = queue) do
    case :queue.out_r(queue.data) do
      {:empty, empty_queue} ->
        {nil, empty_queue}

      {{:value, val}, new_queue} ->
        {val, %Queue{queue | data: new_queue, length: queue.length - 1}}
    end
  end

  @doc """
  Returns the size of the queue based on the internal counter.
  """
  @spec size(StdlibEx.Queue.t()) :: non_neg_integer()
  def size(%Queue{length: length}) when length > 0, do: length

  @doc """
  Returns the size of the queue using the O(n) BIF of the queue module
  """
  @spec size_native(StdlibEx.Queue.t()) :: non_neg_integer
  def size_native(%Queue{data: queue}), do: :queue.len(queue)

  @doc """
  Peeks and returns only the item (not removing) from the head of the queue
  """
  @spec peek_head(StdlibEx.Queue.t()) :: term
  def peek_head(%Queue{data: queue}) do
    case :queue.peek(queue) do
      :empty ->
        nil

      {:value, val} ->
        val
    end
  end

  @doc """
  Peeks and returns only the item (not removing) from the tail of the queue
  """
  @spec peek_tail(StdlibEx.Queue.t()) :: term
  def peek_tail(%Queue{data: queue}) do
    case :queue.peek_r(queue) do
      :empty ->
        nil

      {:value, val} ->
        val
    end
  end

  @spec reverse_queue(StdlibEx.Queue.t()) :: StdlibEx.Queue.t()
  @doc """
  Reverting the order of elements inside the queue
  """
  def reverse_queue(%Queue{} = queue), do: %Queue{queue | data: :queue.reverse(queue.data)}

  @doc """
  Reverting the order of elements inside the queue
  """
  @spec rotate(StdlibEx.Queue.t()) :: StdlibEx.Queue.t()
  def rotate(%Queue{} = queue), do: %Queue{queue | data: :queue.reverse(queue.data)}

  @doc """
  Checks if the queue is empty
  """
  @spec empty?(StdlibEx.Queue.t()) :: boolean
  def empty?(%Queue{length: length}) when length == 0 and length > -1, do: true
  def empty?(%Queue{length: length}) when length > 0, do: false

  @doc """
  Checks if the data structure is a queue
  """
  @spec queue?(StdlibEx.Queue.t()) :: boolean
  def queue?(%Queue{data: queue}), do: :queue.is_queue(queue)
  def queue?(_), do: false

  @doc """
  Checks if the element already exists in the queue
  """
  @spec member?(StdlibEx.Queue.t(), any) :: boolean
  def member?(%Queue{data: queue}, term) do
    :queue.member(term, queue)
  end

  @doc """
  Returns a new queue based on the filter function
  """
  @spec filter_queue(StdlibEx.Queue.t(), (any -> boolean | [any])) :: :queue.queue(any)
  def filter_queue(%Queue{data: queue}, fun) when is_function(fun) do
    :queue.filter(fun, queue)
  end

  @doc """
  Slice the queue based on number. If the lenght == number it will return the queue as is.
  """
  @spec slice(StdlibEx.Queue.t(), non_neg_integer) ::
          {StdlibEx.Queue.t(), StdlibEx.Queue.t()} | StdlibEx.Queue.t()

  def slice(%Queue{length: 0}, _n), do: {:error, "Cannot slice empty queue"}

  def slice(%Queue{length: length} = queue, n) when length == n, do: queue

  def slice(%Queue{length: length} = queue, n) when n > length, do: queue

  def slice(%Queue{data: queue, length: length}, n) when length >= n do
    {q1, q2} = :queue.split(n, queue)

    {
      %Queue{data: q1, length: n},
      %Queue{data: q2, length: length - n}
    }
  end

  @doc """
  Joins 2 queues together
  """
  @spec join_queues(StdlibEx.Queue.t(), StdlibEx.Queue.t()) :: StdlibEx.Queue.t()
  def join_queues(%Queue{data: queue, length: length}, %Queue{data: queue2, length: length2}) do
    %Queue{
      data: :queue.join(queue, queue2),
      length: length + length2
    }
  end

  @doc """
  Returns the queue as binary
  """
  @spec as_binary(StdlibEx.Queue.t()) :: binary
  def as_binary(%Queue{} = queue) do
    :erlang.term_to_binary(queue)
  end

  @doc """
  Returns the queue as list
  """
  @spec to_list(StdlibEx.Queue.t()) :: [term]
  def to_list(%Queue{data: queue}), do: :queue.to_list(queue)

  @doc """
  Returns the serialized queue from binary format
  """
  @spec from_binary(binary) :: StdlibEx.Queue.t()
  def from_binary(bin) when is_binary(bin) do
    case :erlang.binary_to_term(bin) do
      %Queue{} = queue -> queue
      _ -> {:error, "wrong structure or data type"}
    end
  end

  @doc """
  Create a new queue from a list of items
  """
  @spec from_list([term]) :: StdlibEx.Queue.t()
  def from_list(list) when is_list(list) do
    new(list)
  end


  @doc """
  Creates a stream to process every element in the queue
  """
  @spec stream(StdlibEx.Queue.t(), non_neg_integer) ::
          ({:cont, any} | {:halt, any} | {:suspend, any}, any ->
             {:halted, any} | {:suspended, any, (any -> any)})
  def stream(%Queue{} = queue, chunk_num \\ 100) do
    Stream.resource(fn -> {queue, chunk_num} end, &next_chunk/1, fn _ -> :ok end)
  end

  @doc """
  helper function to stream the queue in chunks
  """
  defp next_chunk(:stop), do: {:halt, []}

  defp next_chunk({queue, chunk_num}) do
    case slice(queue, chunk_num) do
      {q1, q2} -> {:queue.to_list(q1.data), {q2, chunk_num}}
      %Queue{} = queue -> {:queue.to_list(queue.data), :stop}
    end
  end
end
