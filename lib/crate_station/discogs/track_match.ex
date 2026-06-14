defmodule CrateStation.Discogs.TrackMatch do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:pending, :matched, :not_found, :ambiguous, :failed]
  @strategies [:exact_title, :fuzzy_title, :isrc, :fingerprint, :manual]

  schema "discogs_track_matches" do
    field :status, Ecto.Enum, values: @statuses

    field :discogs_release_id, :integer
    field :discogs_master_id, :integer
    field :discogs_track_position, :string
    field :discogs_track_title, :string

    field :discogs_artist_ids, {:array, :integer}, default: []
    field :discogs_label_ids, {:array, :integer}, default: []

    field :confidence_score, :float
    field :match_strategy, Ecto.Enum, values: @strategies
    field :match_evidence, :map, default: %{}

    field :last_attempted_at, :utc_datetime
    field :matched_at, :utc_datetime
    field :attempt_count, :integer, default: 0
    field :last_error, :string

    belongs_to :user, CrateStation.Accounts.User
    belongs_to :track, CrateStation.Music.Track

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(track_match, attrs, user_scope) do
    attrs = Map.put(attrs, :user_id, user_scope.user.id)

    changeset(track_match, attrs)
  end

  def changeset(track_match, attrs) do
    track_match
    |> cast(attrs, [
      :user_id,
      :track_id,
      :status,
      :discogs_release_id,
      :discogs_master_id,
      :discogs_track_position,
      :discogs_track_title,
      :discogs_artist_ids,
      :discogs_label_ids,
      :confidence_score,
      :match_strategy,
      :match_evidence,
      :last_attempted_at,
      :matched_at,
      :attempt_count,
      :last_error
    ])
    |> validate_required([
      :track_id,
      :status,
      :user_id
    ])
    |> validate_number(:confidence_score,
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    )
    |> validate_number(:attempt_count, greater_than_or_equal_to: 0)
    |> assoc_constraint(:track)
    |> assoc_constraint(:user)
  end
end
