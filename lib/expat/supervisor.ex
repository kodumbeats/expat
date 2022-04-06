defmodule Expat.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Expat.Registry, name: Expat.Registry},
      {Cluster.Supervisor,
       [
         Application.get_env(:libcluster, :topologies),
         [name: Expat.ClusterSupervisor]
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
