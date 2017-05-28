defmodule BioMonitor.PageController do
  use BioMonitor.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
