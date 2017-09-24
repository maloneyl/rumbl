defmodule Rumbl.Counter do
  use GenServer # generic server

  # CLIENT (INTERFACE)
  # Serves at the API and exists only to send messages
  # to the process that does the work
  #
  # async; send a message and don't bother to await any reply
  def inc(pid), do: GenServer.cast(pid, :inc)

  def dec(pid), do: GenServer.cast(pid, :dec)

  def val(pid) do
    GenServer.call(pid, :val)
  end

  # OTP requires a start_link function
  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val) # spawns a new process and invokes `init`
  end

  # SERVER (IMPLEMENTATION)
  # A process that recursively loops, 
  # processing a message and sending the updates state to itself
  #
  def init(initial_val) do
    {:ok, initial_val}
  end

  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end

  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end
end