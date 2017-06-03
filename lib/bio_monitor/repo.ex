defmodule BioMonitor.Repo do
  use Ecto.Repo, otp_app: :bio_monitor
  use Scrivener, page_size: 10
end
