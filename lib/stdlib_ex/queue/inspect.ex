defimpl Inspect, for: StdlibEx.Queue do
  import Inspect.Algebra

  @spec inspect(StdlibEx.Queue.t(), Inspect.Opts.t()) ::
          :doc_line
          | :doc_nil
          | binary
          | {:doc_collapse, pos_integer}
          | {:doc_force, any}
          | {:doc_break | :doc_color | :doc_cons | :doc_fits | :doc_group | :doc_string, any, any}
          | {:doc_nest, any, :cursor | :reset | non_neg_integer, :always | :break}
  def inspect(%StdlibEx.Queue{} = queue, opts) do
    concat ["#Queue<", to_doc(Enum.to_list(queue), opts) , ">"]
  end
end
