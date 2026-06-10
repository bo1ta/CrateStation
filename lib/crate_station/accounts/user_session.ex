defmodule CrateStation.Accounts.UserSession do
  alias CrateStation.Accounts.{User, JWT}

  @enforce_keys [:user, :access_token, :refresh_token]
  defstruct [:user, :access_token, :refresh_token]

  @type t :: %__MODULE__{
          user: User.t(),
          access_token: String.t(),
          refresh_token: String.t()
        }

  @spec new(User.t(), String.t()) :: t()
  def new(user, refresh_token) when is_binary(refresh_token) do
    %__MODULE__{
      user: user,
      access_token: JWT.generate_access_token(user),
      refresh_token: refresh_token
    }
  end
end
