defmodule CrateStation.Accounts.JWT do
  @moduledoc false

  @access_token_ttl 365 * 24 * 60 * 60
  @issuer "crate_station"

  def generate_access_token(user, opts \\ []) do
    now = System.system_time(:second)
    ttl = Keyword.get(opts, :ttl, @access_token_ttl)

    claims = %{
      "exp" => now + ttl,
      "iat" => now,
      "iss" => @issuer,
      "jti" => random_id(),
      "sub" => to_string(user.id),
      "typ" => "access"
    }

    sign(claims)
  end

  def verify_access_token(token) when is_binary(token) do
    with {:ok, header, payload, signature, signed_data} <- split_token(token),
         true <- valid_header?(header),
         true <- valid_signature?(signed_data, signature),
         true <- valid_payload?(payload) do
      {:ok, payload}
    else
      _ -> {:error, :invalid_access_token}
    end
  end

  def verify_access_token(_), do: {:error, :invalid_access_token}

  defp sign(claims) do
    header = %{"alg" => "HS256", "typ" => "JWT"}
    encoded_header = encode_segment(header)
    encoded_claims = encode_segment(claims)
    signed_data = encoded_header <> "." <> encoded_claims
    signature = sign_data(signed_data) |> Base.url_encode64(padding: false)

    signed_data <> "." <> signature
  end

  defp split_token(token) do
    case String.split(token, ".", parts: 3) do
      [encoded_header, encoded_payload, encoded_signature] ->
        with {:ok, header} <- decode_segment(encoded_header),
             {:ok, payload} <- decode_segment(encoded_payload),
             {:ok, signature} <- Base.url_decode64(encoded_signature, padding: false) do
          {:ok, header, payload, signature, encoded_header <> "." <> encoded_payload}
        else
          _ -> :error
        end

      _ ->
        :error
    end
  end

  defp valid_header?(%{"alg" => "HS256", "typ" => "JWT"}), do: true
  defp valid_header?(_), do: false

  defp valid_payload?(%{"exp" => exp, "iss" => @issuer, "sub" => sub, "typ" => "access"})
       when is_integer(exp) and is_binary(sub) do
    exp > System.system_time(:second)
  end

  defp valid_payload?(_), do: false

  defp valid_signature?(signed_data, signature) do
    Plug.Crypto.secure_compare(sign_data(signed_data), signature)
  end

  defp sign_data(data) do
    :crypto.mac(:hmac, :sha256, secret(), data)
  end

  defp encode_segment(data) do
    data
    |> Jason.encode!()
    |> Base.url_encode64(padding: false)
  end

  defp decode_segment(data) do
    with {:ok, decoded} <- Base.url_decode64(data, padding: false),
         {:ok, parsed} <- Jason.decode(decoded) do
      {:ok, parsed}
    else
      _ -> :error
    end
  end

  defp secret do
    CrateStationWeb.Endpoint.config(:secret_key_base)
  end

  defp random_id do
    16
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
