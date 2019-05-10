defmodule OkrApp.UsersScim do
  alias OkrApp.Users.{User, UserStore}

  # TODO: Find a way to replace this with a real module reference
  def user_module(), do: User

  def get_paged_list(filter: filter, per_page: per_page, start: start_index) do
    users = UserStore.all()
    start_index = max(start_index, 0)

    users
    |> apply_filter(String.split(filter, " "))
    |> Enum.drop(start_index)
    |> Enum.take(per_page)
  end

  def add_user(%User{} = user) do
    Map.from_struct(user)
    |> UserStore.add()
  end

  def update_user(%User{id: _} = user) do
    Map.from_struct(user)
    |> UserStore.add()
  end

  def get_user(id) do
    UserStore.find(id)
  end

  def scim_resource_to_user(
        resource = %{
          "externalId" => id,
          "userName" => user_name,
          "name" => name_map,
          "emails" => emails,
          "active" => active
        }
      ) do
    enterprise_user = Map.get(resource, "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User", %{})

    %User{
      id: id |> clean_value(),
      user_name: user_name |> clean_value(),
      active: active |> clean_value(),
      family_name: Map.get(name_map, "familyName") |> clean_value(),
      given_name: Map.get(name_map, "givenName") |> clean_value(),
      middle_name: Map.get(name_map, "middleName") |> clean_value(),
      manager_id: enterprise_user |> Map.get("manager", %{}) |> Map.get("value", nil) |> clean_value(),
      manager_display_name: enterprise_user |> Map.get("manager", %{}) |> Map.get("displayName", nil) |> clean_value(),
      department: enterprise_user |> Map.get("department") |> clean_value(),
      roles: Map.get(resource, "roles", []),
      emails: emails
    }
  end

  def user_to_scim_resource(%User{
        id: id,
        user_name: user_name,
        family_name: family_name,
        given_name: given_name,
        middle_name: middle_name,
        active: active,
        emails: emails,
        roles: roles,
        manager_id: manager_id,
        manager_display_name: manager_display_name,
        department: department
      }) do
    base_user = %{
      schemas: [
        "urn:ietf:params:scim:schemas:core:2.0:User",
        "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"
      ],
      id: id,
      userName: user_name,
      name: %{
        familyName: family_name,
        givenName: given_name,
        middleName: middle_name
      },
      emails: emails,
      active: active,
      meta: %{
        resourceType: "User",
        location: "/scim/v2/Users/#{id}"
      },
      roles: roles
    }

    enterprise_attributes = %{
      department: department,
      manager: nil
    }

    manager = manager_map(manager_id, manager_display_name)
    enterprise_attributes = %{enterprise_attributes | manager: manager}

    enterprise_attributes =
      enterprise_attributes
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Enum.into(%{})

    Map.put(base_user, :"urn:ietf:params:scim:schemas:extension:enterprise:2.0:User", enterprise_attributes)
  end

  # Okta forces us to use the complex PATCH API to update `active` rather than PUT API
  # However, it should only ever be a replace on the active field
  def apply_scim_operations_to_user(user = %User{}, [%{"op" => "replace", "value" => %{"active" => active_value}}]) do
    {:ok, %{user | active: active_value}}
  end

  # Okta will either send no filter or userName eq "userName"
  defp apply_filter(users, [""]), do: users

  defp apply_filter(users, ["userName", "eq", quoted_val]) do
    value = String.trim(quoted_val, "\"")

    Enum.filter(users, fn %User{user_name: user_name} -> user_name == value end)
  end

  # Empty strings are treated as non-values in Okta
  defp clean_value(value) when value == "" or value == nil, do: nil
  defp clean_value(value), do: value

  # https://tools.ietf.org/html/rfc7643#section-4.3
  defp manager_map(nil, nil), do: nil

  defp manager_map(id, display_name) do
    %{
      value: id,
      displayName: display_name
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end
end
