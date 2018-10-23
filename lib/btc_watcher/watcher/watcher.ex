defmodule BtcWatcher.Watcher do
  use WebSockex

  require Logger

  alias BtcWatcher.Dispatcher
  @btc_ws_url Application.get_env(:btc_watcher, :btc_ws_url)
  @btc_sub  %{op: "unconfirmed_sub"}
  @btc_threshold 50

  def start_link(parent) do
    WebSockex.start_link(@btc_ws_url, __MODULE__, parent)
  end

  def subscribe(pid) do
    {:ok, message} = Poison.encode(@btc_sub)

    WebSockex.send_frame(pid, {:text, message})
  end

  def handle_connect(_frame, parent) do
    Logger.info "BTC Watcher connected"
    {:ok, parent }
  end

  def handle_frame(frame, parent) do
    { _type, msg } = frame

    case Poison.decode(msg) do
      {:ok, data } -> Task.start(fn -> process_tx(data) end)
      {:error, _ } -> Logger.info "Websocket message error"
    end

    {:ok, parent}
  end

  def process_tx(%{"x" => %{"out" => outputs, "inputs" => inputs, "hash" => hash}}) do
    {_in_value, in_address} = inputs
                            |> Enum.map(fn %{"prev_out" => prev_out} -> prev_out end)
                            |> get_max_value
    {out_value, out_address} = outputs |> get_max_value

    btc_value = out_value |> to_btc |> to_int

    unless in_address == out_address or btc_value < @btc_threshold do
      %{
        from: in_address,
        to: out_address,
        symbol: "BTC",
        hash: hash,
        is_btc_tx: true,
        value: out_value,
        token_amount: btc_value,
      }
      |> send
    end
  end

  def send(transaction) do
    # Dispatcher.dispatch(transaction)
    transaction
  end

  defp get_max_value(txs) do
    txs
    |> Enum.reduce({0, 0}, fn %{"addr" => addr, "value" => value}, acc ->
        {prev_value, _prev_address} = acc
        prev_btc_value = prev_value |> to_btc
        btc_value = value |> to_btc

        if btc_value > prev_btc_value,
          do: {value, addr},
        else: acc
      end)
  end


  defp to_btc(value), do: value / 100000000

  defp to_int(nil), do: 0
  defp to_int(0), do: 0
  defp to_int(%Decimal{} = value), do: round_and_convert(value)
  defp to_int(decimal) when is_integer(decimal), do: decimal
  defp to_int(decimal) when is_float(decimal) do
    decimal
    |> Decimal.from_float
    |> round_and_convert
  end

  defp round_and_convert(%Decimal{} = decimal) do
    decimal
    |> Decimal.round
    |> Decimal.to_integer
  end

end
