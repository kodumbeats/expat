defmodule Expat.Registry do
  use GenServer

  require Logger

  @name :expat
  @datadir '/home/snowdum/repos/kdmb/expat/data'

  # Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def get(server) do
    GenServer.call(server, {:get})
  end

  def get(server, name) do
    GenServer.call(server, {:get, name})
  end

  def get(server, name, key) do
    GenServer.call(server, {:get, name, key})
  end

  def put(server, name, key, value) do
    GenServer.cast(server, {:put, name, key, value})
  end

  # Server

  @impl true
  def init(state) do
    :net_kernel.monitor_nodes(true)

    %{
      :ra_system.default_config()
      | name: @name,
        data_dir: @datadir,
        wal_data_dir: @datadir,
        names: :ra_system.derive_names(@name)
    }
    |> :ra_system.start()

    :khepri.start(@name, @name, 'expat')
    {:ok, state}
  end

  @impl GenServer
  def handle_info({:nodeup, _node}, state) do
    # TODO@kodumbeats handle member addition
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodedown, _node}, state) do
    # TODO@kodumbeats handle member disconnects
    {:noreply, state}
  end

  @impl true
  def handle_call({:get}, _from, store) do
    {:ok, reply} = :khepri.list(@name, [])

    collections =
      reply
      |> Map.keys()
      # first element contains collection metadata
      |> Enum.filter(fn x -> length(x) > 0 end)
      # convert to list of collection names
      |> Enum.map(fn x -> hd(x) end)

    {:reply, {:ok, collections}, store}
  end

  @impl true
  def handle_call({:get, name}, _from, store) do
    {:ok, reply} = :khepri.list(@name, [name])

    contents =
      reply
      |> Map.keys()
      # contents should be IDs at this point
      |> Enum.map(fn x -> hd(tl(x)) end)

    {:reply, {:ok, contents}, store}
  end

  @impl true
  def handle_call({:get, name, key}, _from, store) do
    {:ok, reply} = :khepri.get(@name, [name, key])

    data =
      reply
      |> Map.get([name, key])
      |> Map.get(:data)

    {:reply, {:ok, data}, store}
  end

  @impl true
  def handle_cast({:put, name, key, value}, store) when is_atom(name) do
    :khepri.insert(@name, [name, key], value)
    {:noreply, store}
  end
end
