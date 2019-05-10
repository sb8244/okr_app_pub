defmodule OkrApp.Objectives.ObjectiveTest do
  use ExUnit.Case, async: true

  alias OkrApp.Objectives.Objective

  describe "mid_score" do
    test "no key_results is a 0" do
      assert Objective.mid_score(%Objective{key_results: []}) == Decimal.new("0.00")
    end

    test "the key_results mid_score are averaged together" do
      key_results = [
        %{mid_score: Decimal.new("0.1"), cancelled_at: nil},
        %{mid_score: Decimal.new("0.2"), cancelled_at: nil}
      ]

      assert Objective.mid_score(%Objective{key_results: key_results}) == Decimal.new("0.15")
    end

    test "cancelled key_results are not included" do
      key_results = [
        %{mid_score: Decimal.new("0.1"), cancelled_at: nil},
        %{mid_score: Decimal.new("0.2"), cancelled_at: DateTime.utc_now()}
      ]

      assert Objective.mid_score(%Objective{key_results: key_results}) == Decimal.new("0.10")
    end
  end

  describe "final_score" do
    test "no key_results is a 0" do
      assert Objective.final_score(%Objective{key_results: []}) == Decimal.new("0.00")
    end

    test "the key_results final_score are averaged together" do
      key_results = [
        %{final_score: Decimal.new("0.1"), cancelled_at: nil},
        %{final_score: Decimal.new("0.2"), cancelled_at: nil}
      ]

      assert Objective.final_score(%Objective{key_results: key_results}) == Decimal.new("0.15")
    end

    test "cancelled key_results are not included" do
      key_results = [
        %{final_score: Decimal.new("0.1"), cancelled_at: nil},
        %{final_score: Decimal.new("0.2"), cancelled_at: DateTime.utc_now()}
      ]

      assert Objective.final_score(%Objective{key_results: key_results}) == Decimal.new("0.10")
    end

    test "the result is rounded to 2 digits" do
      key_results = [
        %{final_score: Decimal.new("0.166666"), cancelled_at: nil}
      ]

      assert Objective.final_score(%Objective{key_results: key_results}) == Decimal.new("0.17")
    end
  end
end
