defmodule StdlibEx.Queue do
  alias __MODULE__
  import :queue

  @type t() :: %Queue{}

  defstruct data: :queue.new(), length: 0, bloom_filter: nil

  @doc """
  Creates a new queue (empty)
  """
  @spec new :: StdlibEx.Queue.t()
  def new(), do: %Queue{}

  def new(list) when is_list(list) do
    %Queue{data: from_list(list), length: length(list)}
  end

  @doc """
  Creates a new queue from a generator/range or list
  """
  @spec new([any] | Range.t()) :: StdlibEx.Queue.t()
  def new(from..n) when is_integer(from) and is_integer(n) do
    list = Enum.to_list(from..n)
    new(list)
  end

  def new_with_bloom() do
    %Queue{bloom_filter: Bloomex.scalable(1000, 0.1, 0.1, 2)}
  end

  def new_with_bloom(list) when is_list(list) do
    bf =
      Enum.reduce(list, Bloomex.scalable(100_000, 0.1, 0.1, 100), fn x, bf ->
        Bloomex.add(bf, x)
      end)

    %Queue{
      data: from_list(list),
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
    case out(queue.data) do
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
    case out_r(queue.data) do
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
  def size_native(%Queue{data: queue}), do: len(queue)

  @doc """
  Peeks and returns only the item (not removing) from the head of the queue
  """
  @spec peek_head(StdlibEx.Queue.t()) :: term
  def peek_head(%Queue{data: queue}) do
    case peek(queue) do
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
    case peek_r(queue) do
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
  def reverse_queue(%Queue{} = queue), do: %Queue{queue | data: reverse(queue.data)}

  @doc """
  Reverting the order of elements inside the queue
  """
  @spec rotate(StdlibEx.Queue.t()) :: StdlibEx.Queue.t()
  def rotate(%Queue{} = queue), do: %Queue{queue | data: reverse(queue.data)}

  @spec empty?(StdlibEx.Queue.t()) :: boolean
  def empty?(%Queue{length: length}) when length == 0 and length > -1, do: true
  def empty?(%Queue{length: length}) when length > 0, do: false

  @spec queue?(StdlibEx.Queue.t()) :: boolean
  def queue?(%Queue{data: queue}), do: is_queue(queue)
  def queue?(_), do: false

  @spec member?(StdlibEx.Queue.t(), any) :: boolean
  def member?(%Queue{data: queue}, term) do
    member(term, queue)
  end

  @spec filter_queue(StdlibEx.Queue.t(), (any -> boolean | [any])) :: :queue.queue(any)
  def filter_queue(%Queue{data: queue}, fun) when is_function(fun) do
    filter(fun, queue)
  end

  @spec slice(StdlibEx.Queue.t()) :: :empty
  def slice(%Queue{length: 0}), do: :empty

  @spec slice(StdlibEx.Queue.t(), non_neg_integer) ::
          {StdlibEx.Queue.t(), StdlibEx.Queue.t()} | StdlibEx.Queue.t()
  def slice(%Queue{length: length} = queue, n) when length == n, do: queue

  def slice(%Queue{data: queue, length: length}, n) when length >= n do
    {q1, q2} = split(n, queue)

    {
      %Queue{data: q1, length: n},
      %Queue{data: q2, length: length - n}
    }
  end

  @spec join_queues(StdlibEx.Queue.t(), StdlibEx.Queue.t()) :: StdlibEx.Queue.t()
  def join_queues(%Queue{data: queue, length: length}, %Queue{data: queue2, length: length2}) do
    %Queue{
      data: join(queue, queue2),
      length: length + length2
    }
  end

  @spec queue_to_list(StdlibEx.Queue.t()) :: [term]
  def queue_to_list(%Queue{data: queue}), do: to_list(queue)
end
