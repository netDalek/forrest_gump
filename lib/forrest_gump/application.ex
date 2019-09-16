defmodule ForrestGump.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    redises = Application.get_env(:forrest_gump, :redises, [])

    children =
      for {args, index} <- Stream.with_index(redises, 1) do
        {ForrestGump.TcpWorker, args}
      end

    opts = [strategy: :one_for_one, name: ForrestGump.Supervisor, max_restarts: 1000, max_seconds: 1]
    Supervisor.start_link(children, opts)
  end
end
