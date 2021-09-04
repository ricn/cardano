defmodule Cardanoex.StakePoolTest do
  use ExUnit.Case
  doctest Cardanoex.StakePool
  alias Cardanoex.StakePool

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    [wallet: TestHelpers.setup_wallet_with_funds()]
  end

  describe "list stake pools" do
    test "list stake pools successfully" do
      use_cassette "list_stake_pools_successfully" do
        {:ok, stake_pools} = StakePool.list(10_000 * 1_000_000)
        assert length(stake_pools) == 845
      end
    end
  end

  describe "list stake keys" do
    test "list stake keys successfully", %{wallet: wallet} do
      use_cassette "list_stake_keys_successfully" do
        {:ok, stake_keys} = StakePool.list_stake_keys(wallet.id)
        assert stake_keys != nil
      end
    end
  end

  describe "view maintenance actions" do
    test "view maintenance actions successfully" do
      use_cassette "view_maintenance_actions_successfully" do
        {:ok, maintenance_actions} = StakePool.view_maintenance_actions()
        assert maintenance_actions != nil
      end
    end
  end

  describe "trigger maintenance actions" do
    test "trigger maintenance actions successfully" do
      use_cassette "trigger_maintenance_actions" do
        :ok = StakePool.trigger_maintenance_action("gc_stake_pools")
      end
    end
  end

  describe "estimate fee for joining/leaving stake pool" do
    test "estimate fee for joining/leaving successfully", %{wallet: wallet} do
      use_cassette "estimate_fee_for_joining_stake_pool_successfully" do
        {:ok, estimated_fee} = StakePool.estimate_fee(wallet.id)
        assert estimated_fee.estimated_min != nil
        assert estimated_fee.estimated_max != nil
        assert estimated_fee.minimum_coins != nil
        assert estimated_fee.deposit != nil
      end
    end
  end
end
