defmodule Rumbl do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    # A child spec defines the children that an Elixir application will start
    children = [
      # Start the Ecto repository
      supervisor(Rumbl.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Rumbl.Endpoint, [])
      # Start your own worker by calling: Rumbl.Worker.start_link(arg1, arg2, arg3)
      # worker(Rumbl.Worker, [arg1, arg2, arg3]),

      # worker(Rumbl.Counter, [5]) # our arg here is the initial_value
      # By default, child processes have a restart strategy of :permanent,
      # which we could write explicitly like worker(Rumbl.Counter, [5], restart: :permanent).
      # A supervisor will always restart a :permanent GerServer, whether the process
      # crashed or terminated gracefully.
      # :temporary == never restart (useful if restarting is unlikely to resolve the problem or doesn't make sense)
      # :transient == restart only if terminated abnormally, with an exit reason other than :normal, :shutdown or {:shutdown, term}
      # OTP will only restart an application max_restarts times in max_seconds;
      # by default, Elixir will allow 3 restarts in 5 seconds, but this pair of options can be configured.
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rumbl.Supervisor]
    # :one_for_one means if a child dies, only that child will be restarted.
    # :one_for_all == if one child dies, terminate and restart all child processes
    # :rest_for_one == if one child dies, terminate all child processes defined after the dead one, then restart all terminated processes
    # :simple_one_for_one == like :one_for_one but used when a supervisor needs to dynamically supervise processes,
    #   e.g. a web server would use it to supervise web requests, which may be
    #   10, 1000 or 100000 concurrently running processes

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Rumbl.Endpoint.config_change(changed, removed)
    :ok
  end
end
