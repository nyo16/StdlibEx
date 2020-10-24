defmodule StdlibEx.DiskLog do
  defstruct name: nil, path: nil

  @spec open(any, any) :: none
  def open(name, path) when is_atom(name) and is_list(path) do
    case :disk_log.open(name: name, path: path) do
      {:ok, ^name} -> %StdlibEx.DiskLog{name: name, path: path}
      err -> err
    end
  end

  def open(name, path) when is_binary(name) or is_binary(path) do
    open(String.to_atom(name), String.to_charlist(path))
  end


  def log(%StdlibEx.DiskLog{name: name, path: _path}, term) do
    :disk_log.log(name, term)
  end

end
