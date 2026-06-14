defmodule CrateStationWeb.Router do
  use CrateStationWeb, :router

  import CrateStationWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CrateStationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug CrateStationWeb.APIAuth, :fetch_current_user
  end

  pipeline :api_authenticated do
    plug CrateStationWeb.APIAuth, :require_authenticated_user
  end

  scope "/", CrateStationWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:crate_station, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CrateStationWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CrateStationWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{CrateStationWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", CrateStationWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{CrateStationWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  ## API Routes

  scope "/api", CrateStationWeb do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh
    post "/auth/logout", AuthController, :logout
  end

  scope "/api", CrateStationWeb do
    pipe_through [:api, :api_authenticated]

    get "/auth/me", AuthController, :me

    post "/sync/artists/upsert", SyncController, :sync_artists
    post "/sync/albums/upsert", SyncController, :sync_albums
    post "/sync/tracks/upsert", SyncController, :sync_tracks
    post "/sync/playlists/upsert", SyncController, :sync_playlists
    post "/sync/playlists/replace-tracks", SyncController, :replace_playlist_tracks
    post "/sync/events/upsert", SyncController, :sync_events
  end
end
