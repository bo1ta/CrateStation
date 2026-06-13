defmodule CrateStation.Helpers.ClientHelpers do
  def parse_utc_datetime(nil), do: nil
  def parse_utc_datetime(%DateTime{} = datetime), do: DateTime.truncate(datetime, :second)

  def parse_utc_datetime(datetime) when is_binary(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, datetime, _offset} -> DateTime.truncate(datetime, :second)
      {:error, _reason} -> datetime
    end
  end

  def distinct_values(attrs, key) do
    attrs
    |> Enum.map(&client_id(&1, key))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  def client_id(attrs, key) do
    attrs
    |> Map.get(key)
    |> normalize_client_id()
  end

  defp normalize_client_id(nil), do: nil

  defp normalize_client_id(client_id) when is_binary(client_id) do
    case Ecto.UUID.cast(client_id) do
      {:ok, normalized_client_id} -> normalized_client_id
      :error -> client_id
    end
  end

  defp normalize_client_id(client_id), do: client_id
end
