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
  end

  # Starts a child, giving it some options including a unique reference
  # that in our case represents a single response.
  defp spawn_query(backend, query, limit) do
    query_ref = make_ref()
    opts = [backend, query, query_ref, self(), limit]

    {:ok, pid} = Supervisor.start_child(Rumbl.InfoSys.Supervisor, opts)
    {pid, query_ref}
  end
end
