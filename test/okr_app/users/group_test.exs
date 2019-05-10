defmodule OkrApp.Users.GroupTest do
  use ExUnit.Case, async: true
  alias OkrApp.Users.Group

  describe "generate_slug/1" do
    test "the name is made human friendly" do
      assert Group.generate_slug("This is a Test") == "this-is-a-test"
    end

    test "non alpha-numeric is stripped out" do
      assert Group.generate_slug("This is / a Test") == "this-is---a-test"
    end
  end
end
