defmodule BioMonitor.ExAdmin.AdminUser do
  use ExAdmin.Register

  register_resource BioMonitor.AdminUser do
    create_changeset :changeset

    form user do
      inputs do
        input user, :email
        input user, :password
        input user, :password_confirmation
      end
    end
  end
end
