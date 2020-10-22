defmodule StdlibEx.Queue do
  defmodule EmptyQueueException do
    defexception message: "Queue is empty"
  end

  defmodule ArgumentErrorQueueException do
    defexception message: "You didn't provide a queue struct"
  end

  defstruct queue: :queue.new()

  @opaque t(type) :: %__MODULE__{:queue => :queue.queue(type)}
  @opaque t() :: %__MODULE__{:queue => :queue.queue()}

  @doc """
  Creates a new queue (empty)
      iex> inspect StdlibEx.Queue.new()
      "#Queue[]"

  Creates a new queue from list
      iex> inspect StdlibEx.Queue.new([1,2,3])
      "#Queue[1, 2, 3]"

  Creates a new queue from a generator
      iex> inspect StdlibEx.Queue.new(1..3)
      "#Queue[1, 2, 3]"
  """
  @spec new :: StdlibEx.Queue.t()
  def new(), do: %__MODULE__{}

  def new(from..n) do
    %__MODULE__{queue: :queue.from_list(Enum.to_list(from..n))}
  end

  @spec new([any]) :: StdlibEx.Queue.t()
  def new(list) when is_list(list), do: %__MODULE__{queue: :queue.from_list(list)}

  @doc """
  Add an element to the queue
      iex> queue = StdlibEx.Queue.new([:a])
      iex> Enum.to_list StdlibEx.Queue.push(queue, :b)
      [:a, :b]
  """
  @spec push(StdlibEx.Queue.t(), any) :: StdlibEx.Queue.t()
  def push(%__MODULE__{queue: queue}, term) do
    %__MODULE__{queue: :queue.in(term, queue)}
  end

  @doc """
  Add an element to the front of the queue
      iex> queue = StdlibEx.Queue.new([:a])
      iex> Enum.to_list StdlibEx.Queue.push_rear(queue, :b)
      [:b, :a]
  """
  @spec push_rear(StdlibEx.Queue.t(), any) :: StdlibEx.Queue.t()
  def push_rear(%__MODULE__{queue: queue}, term) do
    %__MODULE__{queue: :queue.in_r(term, queue)}
  end

  @spec pop(StdlibEx.Queue.t()) :: {any, StdlibEx.Queue.t()}
  def pop(%__MODULE__{queue: queue}) do
    case :queue.out(queue) do
      {{:value, v}, new_queue} -> {v, %__MODULE__{queue: new_queue}}
      {:empty, new_queue} -> {nil, %__MODULE__{queue: new_queue}}
    end
  end

  @spec pop!(StdlibEx.Queue.t()) :: {any, StdlibEx.Queue.t()}
  def pop!(%__MODULE__{queue: queue}) do
    case :queue.out(queue) do
      {{:value, v}, new_queue} -> {v, %__MODULE__{queue: new_queue}}
      {:empty, _new_queue} -> raise EmptyQueueException
    end
  end

  @spec pop_rear(StdlibEx.Queue.t()) :: {any, StdlibEx.Queue.t()}
  def pop_rear(%__MODULE__{queue: q}) do
    case :queue.out_r(q) do
      {{:value, v}, new_queue} -> {v, %__MODULE__{queue: new_queue}}
      {:empty, new_queue} -> {nil, %__MODULE__{queue: new_queue}}
    end
  end

  @spec pop_rear!(StdlibEx.Queue.t()) :: {any, StdlibEx.Queue.t()}
  def pop_rear!(%__MODULE__{queue: q}) do
    case :queue.out_r(q) do
      {{:value, v}, new_queue} -> {v, %__MODULE__{queue: new_queue}}
      {:empty, _q} -> raise EmptyQueueException
    end
  end

  @spec reverse(StdlibEx.Queue.t()) :: StdlibEx.Queue.t()
  def reverse(%__MODULE__{queue: queue}) do
    %__MODULE__{queue: :queue.reverse(queue)}
  end

  @spec split(StdlibEx.Queue.t(), non_neg_integer) :: {StdlibEx.Queue.t(), StdlibEx.Queue.t()}
  def split(%__MODULE__{queue: queue}, n) do
    with {queue1, queue2} <- :queue.split(n, queue) do
      {%__MODULE__{queue: queue1}, %__MODULE__{queue: queue2}}
    end
  end

  @spec join(StdlibEx.Queue.t(), StdlibEx.Queue.t()) :: StdlibEx.Queue.t()
  def join(%__MODULE__{queue: queue1}, %__MODULE__{queue: queue2}) do
    %__MODULE__{queue: :queue.join(queue1, queue2)}
  end

  @spec first(StdlibEx.Queue.t()) :: any
  def first(%__MODULE__{queue: queue}) do
    case :queue.peek(queue) do
      {:value, val} -> val
      :empty -> nil
    end
  end

  @spec last(StdlibEx.Queue.t()) :: any
  def last(%__MODULE__{queue: queue}) do
    case :queue.peek_r(queue) do
      {:value, val} -> val
      :empty -> nil
    end
  end
end
