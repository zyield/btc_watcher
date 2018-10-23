defmodule BtcWatcherWeb.Router do
  use BtcWatcherWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BtcWatcherWeb do
    pipe_through :api
  end
end
