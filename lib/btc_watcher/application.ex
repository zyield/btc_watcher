defmodule BtcWatcher.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children =
      if watcher_enabled?() do
        [
          supervisor(BtcWatcherWeb.Endpoint, []),
          supervisor(BtcWatcher.Supervisor, []),
          supervisor(BtcWatcher.PanicMonitor, [])
        ]
      else
        [supervisor(BtcWatcherWeb.Endpoint, [])]
      end

    opts = [strategy: :one_for_one, name: BtcWatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    BtcWatcherWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp watcher_enabled? do
    Application.get_env(:btc_watcher, :enable_watcher)
    |> is_true?
  end

  defp is_true?("true"), do: true
  defp is_true?(true), do: true
  defp is_true?(_), do: false
end
