defmodule BioMonitor.ExAdmin.User do
  use ExAdmin.Register

  register_resource BioMonitor.User do
    create_changeset :registration_changeset

    form user do
      inputs do
        input user, :first_name
        input user, :last_name
        input user, :email
        input user, :password
      end
    end
  end
end
