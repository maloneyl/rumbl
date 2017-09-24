defmodule Rumbl.Counter do
  # CLIENT (INTERFACE)
  # Serves at the API and exists only to send messages
  # to the process that does the work
  #
  # async; send a message and don't bother to await any reply
  def inc(pid), do: send(pid, :inc)

  def dec(pid), do: send(pid, :dec)

  def val(pid, timeout \\ 5000) do
    ref = make_ref() # create a value guaranteed to be globally unique
    send(pid, {:val, self(), ref}) # self is our pid

    # after sending the message to the counter above,
    # we block the caller process while waiting for a response
    receive do
      # ^ref means we match only tuples that have that exact ref,
      # not reassigning the value of ref
      # i.e. we match only responses related to our explicit request
      {^ref, val} -> val
    # if no match in a given period, we exit the current process
    # with the :timeout reason code
    after timeout -> exit(:timeout)
    end
  end

  # OTP requires a start_link function
  def start_link(initial_val) do
    {:ok, spawn_link(fn -> listen(initial_val) end)}
    # returns {:ok, pid}, where pid identifies the spawned process;
    # the spawned process then calls listen, which listens for messages and processes them
  end

  # SERVER (IMPLEMENTATION)
  # A process that recursively loops, 
  # processing a message and sending the updates state to itself
  #
  defp listen(val) do
    # blocks to wait for a message
    # then process the trivial :inc, :dec and :val messages
    # then call listen again with the updated state
    receive do
      :inc -> listen(val + 1)
      :dec -> listen(val - 1)
      {:val, sender, ref} ->
        send sender, {ref, val}
        listen(val)
    end
    # this function is tail recursive, meaning it optimizes to a loop instead of a function call;
    # in Elixir, processes are incredibly cheap so this is a great way to manage state
  end
end