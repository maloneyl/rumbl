# A generic module to spawn computations for queries.
# We put all of the results into a single list, 
# wait for each response from each spawned child,
# and finally pick the best one to return to the user.
defmodule Rumbl.InfoSys do
  # module attribute
  @backends [Rumbl.InfoSys.Wolfram]

  # A Result struct to hold each search result
  defmodule Result do
    defstruct score: 0, text: nil, url: nil, backend: nil
  end

  # This start_link is our proxy - calls the start_link to the one defined in our specific backend.
  # Our InfoSys is a :simple_one_for_one worker.
  # Whenever our supervisor calls Supervisor.start_child for InfoSys,
  # it invokes InfoSys.start_link, which then starts the backend to compute its own result.
  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end

  def compute(query, opts \\ []) do
    limit = opts[:limit] || 10
    backends = opts[:backends] || @backends

    # Maps over all backends, calling spawn_query for each one.
    backends
    |> Enum.map(&spawn_query(&1, query, limit))
    |> await_results(opts)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(limit)
  end

  # Starts a child, giving it some options including a unique reference
  # that in our case represents a single response.
  defp spawn_query(backend, query, limit) do
    query_ref = make_ref()
    opts = [backend, query, query_ref, self(), limit]

    {:ok, pid} = Supervisor.start_child(Rumbl.InfoSys.Supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref, query_ref}
  end

  defp await_results(children, opts) do # children are the spawned backends
    timeout = opts[:timeout] || 5000
    timer = Process.send_after(self(), :timedout, timeout) # send itself a message after the given timoeout value
    results = await_result(children, [], :infinity) # we're passing a timeout of infinity
    cleanup(timer)
    results
  end

  defp await_result([head|tail], acc, timeout) do
    {pid, monitor_ref, query_ref} = head

    # We receive a message for each child and add to the accumulator.
    receive do
      # This tuple is what our results look like (see Wolfram).
      {:results, ^query_ref, results} ->
        # If we get a valid result, we drop our monitor.
        # The [:flush] option guaramtees that the :DOWN message is removed
        # from our inbox in case it's delivered before we drop the monitor.
        Process.demonitor(monitor_ref, [:flush])
        await_result(tail, results ++ acc, timeout)

      # The {:DOWN, ...} tuple is a standard Elixir message telling us the process died.
      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
        await_result(tail, acc, timeout)

      # from the timer in await_results
      :timedout ->
        kill(pid, monitor_ref) # kill the backend we are waiting on...
        await_result(tail, acc, 0) # ...and move on to the next one with a timeout of 0 as we can't wait any more

    # the 0 timeout ^ triggers the after branch of the receive call for subsequent backends
    # unless a reply is already in the process inbox
    after
      timeout ->
        kill(pid, monitor_ref)
        await_result(tail, acc, 0)
    end
  end
  defp await_result([], acc, _) do
    acc
  end

  defp kill(pid, ref) do
    Process.demonitor(ref, [:flush])
    Process.exit(pid, :kill)
  end

  defp cleanup(timer) do
    :erlang.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end
end
