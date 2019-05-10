defmodule OkrApp.Users.UserTest do
  use ExUnit.Case, async: true

  alias OkrApp.Users.User

  describe "get_sendable_email/1" do
    test "without anything is an assert" do
      assert User.get_sendable_email(%{emails: nil}) == {:error, :no_email}
    end

    test "the primary address is preferred" do
      assert User.get_sendable_email(%{emails: [
        %{"value" => "1", "primary" => false},
        %{"value" => "2", "primary" => true},
      ]}) == {:ok, "2"}
    end

    test "the non-primary address will be picked if necessary" do
      assert User.get_sendable_email(%{emails: [
        %{"value" => "1", "primary" => false},
        %{"value" => "2", "primary" => false},
      ]}) == {:ok, "1"}
    end
  end
end
