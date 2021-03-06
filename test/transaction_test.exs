defmodule TDS.Ecto.TransactionTest do
  # We can keep this test async as long as it
  # is the only one access the transactions table
  use ExUnit.Case#, async: true

  require Ecto.Integration.PoolRepo, as: PoolRepo

  defmodule UniqueError do
    defexception [:message]
  end

  setup do
    PoolRepo.delete_all "transactions"
    :ok
  end

  defmodule Trans do
    use Ecto.Schema

    schema "transactions" do
      field :text, :string
    end
  end

  test "transaction returns value" do
    x = PoolRepo.transaction(fn ->
      PoolRepo.transaction(fn ->
        42
      end)
    end)
    assert x == {:ok, {:ok, 42}}
  end

  test "transaction re-raises" do
    assert_raise UniqueError, fn ->
      PoolRepo.transaction(fn ->
        PoolRepo.transaction(fn ->
          raise UniqueError
        end)
      end)
    end
  end
end
