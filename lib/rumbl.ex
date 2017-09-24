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
      supervisor(Rumbl.Endpoint, []),
      # Start your own worker by calling: Rumbl.Worker.start_link(arg1, arg2, arg3)
      # worker(Rumbl.Worker, [arg1, arg2, arg3]),
      worker(Rumbl.Counter, [5]) # our arg here is the initial_value
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rumbl.Supervisor]
    # one_for_one means if a child dies, only that child will be restarted.
    # If all resources depend on some common service, we might specify
    # one_for_all to kill and restart all child process if any child dies.

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Rumbl.Endpoint.config_change(changed, removed)
    :ok
  end
end
