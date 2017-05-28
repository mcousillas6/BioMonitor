defmodule BioMonitor.SessionView do
  use BioMonitor.Web, :view

  def render("delete.json", %{users: users}) do
    %{users: render_many(users, BioMonitor.UserView, "user.json")}
  end
end
