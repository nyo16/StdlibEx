defimpl Inspect, for: StdlibEx.Queue do
  import Inspect.Algebra

  def inspect(%StdlibEx.Queue{} = queue, opts) do
    concat ["#Queue", to_doc(Enum.to_list(queue), opts), ""]
  end
end