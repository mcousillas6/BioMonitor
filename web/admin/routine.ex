defmodule BioMonitor.ExAdmin.Routine do
  use ExAdmin.Register

  register_resource BioMonitor.Routine do
    create_changeset :changeset

    form routine do
      inputs do
        input routine, :title
        input routine, :strain
        input routine, :medium
        input routine, :target_temp
        input routine, :target_ph
        input routine, :target_density
        input routine, :estimated_time_seconds
        input routine, :extra_notes
      end
    end
  end
end
