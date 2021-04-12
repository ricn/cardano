defmodule Cardano.TransactionTest do
  use ExUnit.Case
  doctest Cardano.Transaction
  alias Cardano.Transaction
  alias TestHelpers

  setup_all do
    [wallet: TestHelpers.setup_wallet_with_funds()]
  end

  describe "estimate fee" do
    test "estimate fee successfully", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 42_000_000, unit: "lovelace"}
          }
        ]
      }

      {:ok, estimated_fees} = Transaction.estimate_fee(wallet.id, transaction)
      assert estimated_fees != nil
    end

    test "try estimate fee with 1 lovelace", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1, unit: "lovelace"}
          }
        ]
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      expected_message =
        "Some outputs have ada values that are too small. There's a minimum ada value specified by the protocol that each output must satisfy. I'll handle that minimum value myself when you do not explicitly specify an ada value for an output. Otherwise, you must specify enough ada. Here are the problematic outputs:   - Expected min coin value: 1.000000     TxOut:       address: 00f8227b...6e607d73       coin: 0.000001       tokens: [] "

      assert expected_message == message
    end

    test "try estimate fee with no payments", %{wallet: wallet} do
      transaction = %{
        payments: []
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      expected_message = "Error in $.payments: parsing NonEmpty failed, unexpected empty list"
      assert expected_message == message
    end

    test "estimate fee with assets included", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"},
            assets: [
              %{policy_id: "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7", asset_name: "", quantity: 1}
            ]
          }
        ]
      }

      {:ok, estimated_fees} = Transaction.estimate_fee(wallet.id, transaction)
      assert estimated_fees != nil
    end

    test "estimate fee with too low amount of ada", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 0_407_406, unit: "lovelace"},
            assets: [
              %{policy_id: "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7", asset_name: "", quantity: 1}
            ]
          }
        ]
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)
      assert "Some outputs have ada values that are too small. There's a minimum ada value specified by the protocol that each output must satisfy. I'll handle that minimum value myself when you do not explicitly specify an ada value for an output. Otherwise, you must specify enough ada. Here are the problematic outputs:   - Expected min coin value: 1.407406     TxOut:       address: 00f8227b...6e607d73       coin: 0.407406       tokens:         - policy: 6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7           tokens:             - token:               quantity: 1 " == message
    end

    test "estimate fee with too low amount of test asset", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"},
            assets: [
              %{policy_id: "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7", asset_name: "", quantity: 0}
            ]
          }
        ]
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)
      assert "Error in $.payments[0].assets: parsing AddressAmount failed, Error while deserializing token map from JSON: Encountered zero-valued quantity for token '' within policy '6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7'." == message
    end

    test "estimate fee with invalid policy id", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"},
            assets: [
              %{policy_id: "7a8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7", asset_name: "", quantity: 1}
            ]
          }
        ]
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)
      assert "I can't process this payment as there are not enough funds available in the wallet. I am missing: coin: 0.000000 tokens:   - policy: 7a8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7     token:     quantity: 1 " == message
    end

  end
end
