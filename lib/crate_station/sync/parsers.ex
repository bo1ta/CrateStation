defmodule CrateStation.Sync.Parsers do
  def parse_uuid!(map, key) do
    uuid_string = Map.fetch!(map, key)
    Ecto.UUID.cast!(uuid_string)
  end

  def parse_uuid(map, key) when is_binary(key) and is_map_key(map, key) do
    case Ecto.UUID.cast(Map.get(map, key)) do
      {:ok, uuid} ->
        uuid

      :error ->
        nil
    end
  end

  def parse_uuid(_, _), do: nil

  def parse_utc_datetime(datetime) when is_binary(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, datetime, _offset} -> DateTime.truncate(datetime, :second)
      {:error, _reason} -> datetime
    end
  end

  def parse_utc_datetime(%DateTime{} = datetime), do: DateTime.truncate(datetime, :second)
  def parse_utc_datetime(nil), do: nil

  def parse_atom(attrs, key) do
    case Map.get(attrs, key) do
      nil -> nil
      value -> String.to_atom(value)
    end
  end

  def distinct_uuids(attrs, key) do
    attrs
    |> Enum.map(&parse_uuid(&1, key))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end
end
