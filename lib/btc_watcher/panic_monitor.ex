defmodule BtcWatcher.PanicMonitor do
  use GenServer

  @tx_timeout 3600 # 1 hour

  require Logger

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: Panic)
  end

  def update_time(%{timestamp: timestamp}) do
    GenServer.cast(Panic, timestamp)
  end

  def init(state) do
    schedule_check(0)

    {:ok, state}
  end

  def handle_cast(timestamp, state) do
    new_state = Map.put(state, :timestamp, timestamp)

    {:noreply, new_state}
  end

  def handle_info(:check, state) do
    perform_check(state)
    schedule_check(30 * 60 * 1000) # half an hour

    {:noreply, state}
  end

  def perform_check(state) do
    with %{timestamp: timestamp} <- state do
      time_now = DateTime.utc_now |> DateTime.to_unix

      if (time_now - timestamp > @tx_timeout), do: panic()
    end
  end

  def schedule_check(timeout) do
    Process.send_after(self(), :check, timeout)
  end

  def panic do
    Sentry.capture_message("BTC Watcher is taking a break")
    Logger.error "No transactions for more than an hour timeout"
  end
end
