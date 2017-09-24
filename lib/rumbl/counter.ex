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
    GenServer.call(pid, :val) # no need to worry about setting up references ourselves
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
    Process.send_after(self(), :tick, 1000) # send itself a tick every 1000ms
    {:ok, initial_val}
  end

  # as with channels, out-of-band messages are handled inside the handle_info callback
  # our one here simulates a countdown
  def handle_info(:tick, val) when val <= 0, do: raise "boom!" # make it crash so we can see it restart by the supervisor
  def handle_info(:tick, val) do
    IO.puts "tick #{val}"
    Process.send_after(self(), :tick, 1000)
    {:noreply, val - 1}
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