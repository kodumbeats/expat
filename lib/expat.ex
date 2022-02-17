defmodule Expat do
  use Application

  alias Expat.Registry, as: Registry
  alias Expat.Registry.Bucket, as: KV

  @impl true
  def start(_type, _args) do
    {:ok, pid} = Expat.Supervisor.start_link(name: Expat.Supervisor)
    Expat.Registry.create(Expat.Registry, :containers)
    {:ok, pid}
  end

  def name do
    "redis"
  end
  def image do
    "redis:latest"
  end
  def conf do
    %{
      "AttachStdin" => false,
      "Image" => image(),
      "Volumes" => %{},
      "ExposedPorts" => %{},
    }
  end

  def listImageIds do
    Docker.Images.list()
    # Grab just the ids
    |> Enum.map(&(&1["Id"]))
    # Remove prepended "sha256:"
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(&hd(tl(&1)))
  end

  def up do
    pull(image())
    run!(name(), conf())
    :ok
  end

  @doc"""
  image: `image:tag` 
  """
  def pull(image) do
    [image, tag] = String.split(image, ":")
    Docker.Images.pull(image, tag)
  end

  def run!(name, conf = %{}) do
    id = create!(name, conf)
    start!(id)
  end

  def create!(name, conf = %{}) do
    id = case Docker.Containers.create(conf, name) do
      %{"Id" => id, "Warnings" => _warnings} -> id
      %{"message" => message} -> raise message
    end
    {:ok, containers} = Registry.lookup(Registry, :containers)
    KV.put(containers, id, :created)
    id
  end

  def start!(id) do
    case Docker.Containers.start(id) do
      "" -> :ok
      error -> raise error
    end
    {:ok, containers} = Registry.lookup(Registry, :containers)
    KV.put(containers, id, :running)
  end
end
