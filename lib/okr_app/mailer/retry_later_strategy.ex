defmodule OkrApp.Mailer.RetryLaterStrategy do
  @behaviour Bamboo.DeliverLaterStrategy

  @moduledoc """
  Async delivery strategy that will retry an email send multiple times over a delayed period of time.
  """

  @doc false
  def deliver_later(adapter, email, config) do
    GenRetry.retry(fn ->
      adapter.deliver(email, config)
    end, retries: 3, delay: 10_000, exp_base: 1, jitter: 0.2)
  end
end
