defmodule StdlibEx.DiskLog do
  defstruct name: nil, path: nil

  def open(name, path) when is_binary(name) or is_binary(path) do
    open(String.to_atom(name), String.to_charlist(path))
  end

  @spec open(any, any) :: none
  def open(name, path) when is_atom(name) and is_list(path) do
    case :disk_log.open(name: name, file: path) do
      {:ok, ^name} -> %__MODULE__{name: name, path: path}
      err -> err
    end
  end

  def log(%__MODULE__{name: name, path: _path}, terms) when is_list(terms) do
    :disk_log.log_terms(name, terms)
  end

  def log(%__MODULE__{name: name, path: _path}, term) do
    :disk_log.log(name, term)
  end

  def async_log(%__MODULE__{name: name, path: _path}, terms) when is_list(terms) do
    :disk_log.alog(name, terms)
  end

  def async_log(%__MODULE__{name: name, path: _path}, term) do
    :disk_log.alog(name, term)
  end

  def info(%__MODULE__{name: name, path: _path}), do: :disk_log.info(name)

  def read_chunk(%__MODULE__{name: name, path: _path}) do
    :disk_log.chunk(name, :start)
  end

  def read_chunk(
        %__MODULE__{name: name, path: _path},
        {:continuation, _pid, _, _} = continuation
      ) do
    :disk_log.chunk(name, continuation)
  end

  def close(%__MODULE__{name: name, path: _path}) do
    :disk_log.close(name)
  end

  def flush(%__MODULE__{name: name, path: _path}), do: :disk_log.sync(name)

  def sync(%__MODULE__{name: name, path: _path}), do: :disk_log.sync(name)

  def stream(log), do: __MODULE__.Stream.create(log)
end
