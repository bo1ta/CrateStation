defmodule CrateStationWeb.PageController do
  use CrateStationWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
