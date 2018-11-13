defmodule BtcWatcher.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BtcWatcherWeb.Endpoint, []),
      # Start your own worker by calling: BtcWatcher.Worker.start_link(arg1, arg2, arg3)
      # worker(BtcWatcher.Worker, [arg1, arg2, arg3]),
      supervisor(BtcWatcher.Supervisor, [])
    ]

    children =
      if watcher_enabled? do
        [
          supervisor(BtcWatcherWeb.Endpoint, []),
          supervisor(BtcWatcher.Supervisor, [])
        ]
      else
        [supervisor(BtcWatcherWeb.Endpoint, [])]
      end
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BtcWatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BtcWatcherWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp watcher_enabled? do
    Application.get_env(:btc_watcher, :enable_watcher) |> is_true?
  end

  defp is_true?("true"), do: true
  defp is_true?(true), do: true
  defp is_true?(_), do: false
end
