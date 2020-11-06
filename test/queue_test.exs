defmodule QueueTest do
  use ExUnit.Case
  doctest StdlibEx.Queue
  alias StdlibEx.Queue

  test "test new, size, append, prepend, pop and pop_last" do
    q = Queue.new(1..10)
    assert Queue.size(q) == 10
    assert Queue.size_native(q) == 10
    q = Queue.append(q, :new_item)
    assert Queue.size(q) == 11
    {val, q} = Queue.pop(q)
    assert val == 1
    {val, q } = Queue.pop_last(q)
    assert val == :new_item
    q = Queue.prepend(q, :new_item_head)
    assert Queue.size(q) == 10
    {val, _q} = Queue.pop(q)
    assert val == :new_item_head
  end


  # test "push, pop, push_tail, pop, pop_tail" do
  #   q = Queue.new(1..10)
  #   q = Queue.push(q, 11)
  #   assert 11 == Queue.head(q)
  #   assert 11 == :queue.head(q.queue)

  # end

end
