defmodule ForrestGump.TcpWorker do
  use GenServer
  require Logger

  @timeout 10000
  @default_interval 500
  @default_batch_size 10

  defstruct name: "", redis: nil, interval: 0, batch_size: 0

  def start_link(redis_args) do
    GenServer.start_link(__MODULE__, redis_args, [])
  end

  @impl true
  def init({host, port} = redis_args) do
    Logger.info("connecting to #{inspect(redis_args)}")
    host = String.to_charlist(host)

    {:ok, redis} = :gen_tcp.connect(host, port, [:binary, {:packet, :raw}, {:active, false}])

    {:ok,
     %__MODULE__{
       redis: redis,
       batch_size: Application.get_env(:forrest_gump, :batch_size, @default_batch_size),
       interval: Application.get_env(:forrest_gump, :interval, @default_interval),
       name: "#{host}_#{port}"
     }, 0}
  end

  @impl true
  def handle_info(:timeout, state) do
    times =
      for _ <- 1..state.batch_size do
        :timer.sleep(state.interval)
        ping(state.redis)
      end

    mean = Enum.sum(times) / Enum.count(times)
    Logger.info("REDIS #{state.name} PING-PONG MAX:#{Enum.max(times)} MEAN:#{mean} microseconds")
    {:noreply, state, 0}
  end

  defp ping(redis) do
    {t, _} =
      :timer.tc(fn ->
        :ok = :gen_tcp.send(redis, "PING\r\n")
        {:ok, "+PONG\r\n"} = :gen_tcp.recv(redis, 7, @timeout)
      end)

    t
  end
end
