defmodule Rumbl.InfoSys.Supervisor do
  # prepare our code to use the Supervisor API
  # (implementing a behavior, which is an API contract)
  use Supervisor 

  # starts the supervisor
  def start_link() do
    # Similar to GenServer.start_link,
    # this function requires the name of the module implementing the supervisor behavior
    # and the initial value we provide in init.
    #
    # We use the __MODULE__ compiler directive to pick up this current module's name.
    # We pass the initial state of an empty list, which we don't intend to use.
    # :name - so we can reach the supervisor with that name instead of using its pid.
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # the function that's required by the contract and that initializes our workers
  def init(_opts) do
    # the child spec
    children = [
      worker(Rumbl.InfoSys, [], restart: :temporary) # [] is the initial state
    ]

    # :simple_one_for_one doesn't start anything children;
    # it waits for us to explicitly ask it to start a child process,
    # handling any crashes just as a :one_for_one supervisor would
    supervise children, strategy: :simple_one_for_one
  end
end