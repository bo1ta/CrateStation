defmodule CrateStation.Sync.Payloads do
  alias CrateStation.Sync.Parsers

  @spec artist_entry(map(), now: DateTime.t(), user_id: integer()) :: map()
  def artist_entry(attr, keywords) do
    now = Keyword.fetch!(keywords, :now)
    user_id = Keyword.fetch!(keywords, :user_id)

    %{
      client_id: Parsers.parse_uuid!(attr, "client_id"),
      name: attr["name"],
      slug: attr["slug"],
      user_id: user_id,
      inserted_at: now,
      updated_at: now
    }
  end

  @spec album_entry(map(), now: DateTime.t(), user_id: integer()) ::
          map()
  def album_entry(attr, keywords) do
    now = Keyword.fetch!(keywords, :now)
    user_id = Keyword.fetch!(keywords, :user_id)

    %{
      client_id: Parsers.parse_uuid!(attr, "client_id"),
      title: attr["title"],
      year: attr["year"],
      genre: attr["genre"],
      artist_id: attr["artist_id"],
      user_id: user_id,
      inserted_at: now,
      updated_at: now
    }
  end

  @spec track_entry(map(),
          user_id: integer(),
          now: DateTime.t()
        ) :: map()
  def track_entry(attr, keywords) do
    now = Keyword.fetch!(keywords, :now)
    user_id = Keyword.fetch!(keywords, :user_id)

    %{
      client_id: Parsers.parse_uuid!(attr, "client_id"),
      title: attr["title"],
      duration: attr["duration"],
      track_number: attr["track_number"],
      disc_number: attr["disc_number"],
      year: attr["year"],
      genre: attr["genre"],
      bpm: attr["bpm"],
      song_key: attr["song_key"],
      play_count: attr["play_count"],
      rating: attr["rating"],
      is_favorite: attr["is_favorite"],
      last_played_at: Parsers.parse_utc_datetime(attr["last_played_at"]),
      imported_at: Parsers.parse_utc_datetime(attr["imported_at"]),
      album_id: attr["album_id"],
      artist_id: attr["artist_id"],
      user_id: user_id,
      inserted_at: now,
      updated_at: now
    }
  end

  @spec playlist_entry(map(), user_id: integer(), now: DateTime.t()) :: map()
  def playlist_entry(attr, keywords) do
    now = Keyword.fetch!(keywords, :now)
    user_id = Keyword.fetch!(keywords, :user_id)

    %{
      client_id: Parsers.parse_uuid!(attr, "client_id"),
      name: attr["name"],
      kind: String.to_atom(attr["kind"]),
      user_id: user_id,
      inserted_at: now,
      updated_at: now
    }
  end

  @spec playlist_track_entry(map(),
          user_id: integer(),
          playlist_id: integer(),
          now: DateTime.t()
        ) :: map()
  def playlist_track_entry(attr, keywords) do
    now = Keyword.fetch!(keywords, :now)
    user_id = Keyword.fetch!(keywords, :user_id)
    playlist_id = Keyword.fetch!(keywords, :playlist_id)

    track_id = Map.fetch!(attr, "track_id")

    %{
      user_id: user_id,
      playlist_id: playlist_id,
      track_id: track_id,
      position: attr["position"],
      inserted_at: now,
      updated_at: now
    }
  end

  @spec playback_event_entry(map(), user_id: integer(), now: DateTime.t()) :: map()
  def playback_event_entry(attr, keywords) do
    now = Keyword.fetch!(keywords, :now)
    user_id = Keyword.fetch!(keywords, :user_id)

    track_id = Map.fetch!(attr, "track_id")

    %{
      user_id: user_id,
      client_id: Parsers.parse_uuid!(attr, "client_event_id"),
      event_type: String.to_atom(attr["event_type"]),
      played_at: Parsers.parse_utc_datetime(attr["played_at"]),
      position_seconds: attr["position_seconds"],
      duration_seconds: attr["duration_seconds"],
      context_type: Parsers.parse_atom(attr, "context_type"),
      context_client_id: Parsers.parse_uuid(attr, "context_client_id"),
      track_id: track_id,
      inserted_at: now,
      updated_at: now
    }
  end
end
