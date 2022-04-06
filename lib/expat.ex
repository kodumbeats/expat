defmodule Expat do
  use Application

  alias Expat.Registry, as: KV

  @impl true
  def start(_type, _args) do
    Expat.Supervisor.start_link(name: Expat.Supervisor)
  end

  def listImageIds do
    Docker.Images.list()
    # Grab just the ids
    |> Enum.map(& &1["Id"])
    # Remove prepended "sha256:"
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(&hd(tl(&1)))
  end

  def listContainerIds do
    Docker.Containers.list()
    # Grab just the ids
    |> Enum.map(& &1["Id"])
  end

  def up do
    path = Path.join(File.cwd!(), "compose.yml")
    {:ok, compose} = YamlElixir.read_from_file(path)
    services = Map.get(compose, "services")
    Enum.each(services, fn {k, v} -> {pull_and_run(k, v)} end)
  end

  def pull_and_run(name, props) do
    pull(props["image"])

    ports = props["ports"]
    port = hd(ports)
    [ext, _int] = String.split(port, ":")
    ext = ext <> "/tcp"

    conf = %{
      "AttachStdin" => false,
      "Image" => props["image"],
      "Volumes" => %{},
      "ExposedPorts" => %{
        ext => %{}
      }
    }

    run!(name, conf)
  end

  @doc """
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
    id =
      case Docker.Containers.create(conf, name) do
        %{"Id" => id, "Warnings" => _warnings} -> id
        %{"message" => message} -> raise message
      end

    KV.put(KV, :containers, id, :created)
    id
  end

  def start!(id) do
    case Docker.Containers.start(id) do
      "" -> :ok
      error -> raise error
    end

    KV.put(KV, :containers, id, :running)
  end

  def getContainers() do
    KV.get(KV, :containers)
  end

  def getContainer(id) do
    KV.get(KV, :containers, id)
  end
end
