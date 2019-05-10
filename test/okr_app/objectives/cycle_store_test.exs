defmodule OkrApp.Objectives.CycleStoreTest do
  use OkrApp.DataCase, async: true

  alias OkrApp.Objectives.CycleStore

  describe "all/2" do
    test "all okrs are returned" do
      user = Test.Factories.User.create!(%{active: true})
      cycle1 = Test.Factories.Cycle.create!(user: user)
      cycle2 = Test.Factories.Cycle.create!(user: user)

      assert CycleStore.all(%{}) == [cycle1, cycle2]
    end

    test "active=true" do
      now = Timex.now()
      in_future_5_minutes = Timex.shift(now, minutes: 5)

      in_past_1_second = Timex.shift(now, seconds: -1)
      in_past_5_minutes = Timex.shift(now, minutes: -5)

      user = Test.Factories.User.create!(%{active: true})
      _ends_past_2 = Test.Factories.Cycle.create!(%{"starts_at" => in_past_5_minutes, "ends_at" => in_past_1_second}, user: user)
      _weird_timing = Test.Factories.Cycle.create!(%{"starts_at" => in_future_5_minutes, "ends_at" => in_past_5_minutes}, user: user)
      _starts_future = Test.Factories.Cycle.create!(%{"starts_at" => in_future_5_minutes, "ends_at" => in_future_5_minutes}, user: user)
      cycle = Test.Factories.Cycle.create!(%{"starts_at" => in_past_5_minutes, "ends_at" => in_future_5_minutes}, user: user)
      cycle2 = Test.Factories.Cycle.create!(%{"starts_at" => in_past_1_second, "ends_at" => in_future_5_minutes}, user: user)

      assert CycleStore.all(%{active: true}) == [cycle, cycle2]
      assert CycleStore.all(%{"active" => "true"}) == [cycle, cycle2]
    end

    test "present_or_future=true" do
      now = Timex.now()
      in_future_5_minutes = Timex.shift(now, minutes: 5)

      in_past_1_second = Timex.shift(now, seconds: -1)
      in_past_5_minutes = Timex.shift(now, minutes: -5)

      user = Test.Factories.User.create!(%{active: true})
      _ = Test.Factories.Cycle.create!(%{"ends_at" => in_past_1_second}, user: user)
      _ = Test.Factories.Cycle.create!(%{"ends_at" => in_past_5_minutes}, user: user)
      cycle2 = Test.Factories.Cycle.create!(%{"ends_at" => in_future_5_minutes}, user: user)
      cycle3 = Test.Factories.Cycle.create!(%{"ends_at" => in_future_5_minutes}, user: user)

      assert CycleStore.all(%{present_or_future: true}) == [cycle2, cycle3]
      assert CycleStore.all(%{"present_or_future" => "true"}) == [cycle2, cycle3]
    end
  end
end
