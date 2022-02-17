defmodule Expat.Registry do
  use GenServer
  # Agent
  defmodule Bucket do
    def start_link(_opts) do
      Agent.start_link(fn -> %{} end)
    end
    def list(bucket) do
      Agent.get(bucket, &(&1))
    end
    def get(bucket, key) do
      Agent.get(bucket, &Map.get(&1, key))
    end
    def put(bucket, key, value) do
      Agent.update(bucket, &Map.put(&1, key, value))
    end
    def delete(bucket, key) do
      Agent.update(bucket, &Map.delete(&1, key))
    end
  end

  # Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end
  def list(server) do
    GenServer.call(server, {:list})
  end
  def list(server, name) do
    GenServer.call(server, {:list, name})
  end
  def get(server, name) do
    GenServer.call(server, {:lookup, name})
  end
  def get(server, name, key) do
    GenServer.call(server, {:get, name, key})
  end
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end
  def put(server, name, key, value) do
    GenServer.cast(server, {:put, name, key, value})
  end
  def delete(server, name) do
    GenServer.cast(server, {:delete, name})
  end
  def delete(server, name, key) do
    GenServer.cast(server, {:delete, name, key})
  end

  # Server

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_call({:list}, _from, store) do
    {:reply, {:ok, store}, store}
  end

  @impl true
  def handle_call({:list, name}, _from, store) do
    reply = Map.fetch!(store, name) |> Bucket.list()
    {:reply, reply, store}
  end

  @impl true
  def handle_call({:get, name, key}, _from, store) do
    bucket = Map.fetch!(store, name)
    reply = {:ok, Bucket.get(bucket, key)}
    {:reply, reply, store}
  end

  @impl true
  def handle_cast({:create, name}, store) do
    if Map.has_key?(store, name) do
      {:noreply, store}
    else
      {:ok, bucket} = Expat.Registry.Bucket.start_link([])
      {:noreply, Map.put(store, name, bucket)}
    end
  end

  @impl true
  def handle_cast({:delete, name}, store) do
    {bucket, store} = Map.pop!(store, name)
    Agent.stop(bucket)
    {:noreply, store}
  end

  @impl true
  def handle_cast({:delete, name, key}, store) do
    Map.fetch!(store, name)
      |> Bucket.delete(key)
    {:noreply, store}
  end

  @impl true
  def handle_cast({:put, name, key, value}, store) do
    Map.fetch!(store, name)
      |> Bucket.put(key, value)
    {:noreply, store}
  end
end
