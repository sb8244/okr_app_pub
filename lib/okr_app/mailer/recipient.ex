defmodule OkrApp.Mailer.Recipient do
  @enforce_keys [:to, :first_name, :slug]
  defstruct @enforce_keys ++ [type: :user]

  def new(%{to: to, first_name: first_name, slug: slug}) when is_bitstring(to) and is_bitstring(first_name) and is_bitstring(slug) do
    %__MODULE__{
      to: to,
      first_name: first_name,
      slug: slug
    }
  end
end
