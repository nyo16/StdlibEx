defimpl Inspect, for: StdlibEx.Queue do
  import Inspect.Algebra

  def inspect(%StdlibEx.Queue{len: len} = _queue, opts) do
    concat ["#Queue<", to_doc([size: len], opts), ">"]
  end
end
