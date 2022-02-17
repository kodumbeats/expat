defmodule Expat.Registry do
  # Bucket for KV storage
  defmodule Bucket do
    def start_link(_opts) do
      Agent.start_link(fn -> %{} end)
    end
    def all(bucket) do
      Agent.get(bucket, &Map.new(&1))
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

  # Registry Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def all(server, name) do
    GenServer.call(server, {:all, name})
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

  # Registry Server
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_call({:all, name}, _from, store) do
    bucket = Map.fetch!(store, name)
    reply =  {:ok, Bucket.all(bucket)}
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
  def handle_cast({:put, name, key, value}, store) do
    Map.fetch!(store, name)
      |> Bucket.put(key, value)
    {:noreply, store}
  end
end
