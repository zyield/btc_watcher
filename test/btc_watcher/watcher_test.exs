defmodule BtcWatcher.WatcherTest do
  use ExUnit.Case
  alias BtcWatcher.Watcher

  describe "BTC watcher" do
    setup do

      with {:ok, tx_fixture } <- File.read("test/fixtures/tx_above_threshold.json"),
           {:ok, small_tx_fixture } <- File.read("test/fixtures/tx_below_threshold.json"),
           {:ok, tx} <- Poison.decode(tx_fixture),
           {:ok, small_tx} <- Poison.decode(small_tx_fixture)
      do
        %{btc_tx: tx, small_btc_tx: small_tx}
      end

    end

    test "process_tx/1 processes the btc transaction if amount above 50 BTC", %{btc_tx: tx} do
      assert Watcher.process_tx(tx) |> is_map == true
    end
    test "process_tx/1 doesn't save the btc transaction if value below 50 BTC", %{small_btc_tx: tx} do
      assert assert Watcher.process_tx(tx) == nil
    end
    test "process_tx/1 returns the tx data with correct params", %{btc_tx: tx} do
      processed_tx = tx |> Watcher.process_tx

      assert processed_tx.from == "1ADjKWiwKLXfD1fjoeLhuC7qPPnU4te9Wm"
      assert processed_tx.to == "1JRf44khKEmYNboh5BVzjkV5nBqk6Km6D3"
      assert processed_tx.hash == "8164c56833d124866643024b5876627daed96ddb2a947024b5b6451a53c6ee22"
      assert processed_tx.is_btc_tx == true
      assert processed_tx.value == 15000000000
      assert processed_tx.token_amount == 150
    end
  end
end
