alias Expat.Registry, as: Registry
alias Expat.Registry.Bucket, as: KV
defmodule R do
  def reload! do
    Mix.Task.reenable "compile.elixir"
    Application.stop(Mix.Project.config[:app])
    Mix.Task.run "compile.elixir"
    Application.start(Mix.Project.config[:app], :permanent)
  end
end
