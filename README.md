# Expat

Container orchestration API in Elixir, using the Docker API as a runtime.

This project maintains a centralized state via Raft consensus with the help of [ra](https://github.com/rabbitmq/ra)
and [khepri](https://github.com/rabbitmq/khepri) to provide distributed, persistent state across nodes. 

**Until this message is removed, assume project is super broken**

## Goals
- [x] No reliance on consul/etcd to provide distributed state
- [x] Parse basic `compose.yml` files in the project directory
- [ ] Simple ingress via manual webserver work
- [ ] cross-node communication
- [ ] dogfood it :dog:

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `expat` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:expat, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/expat>.

