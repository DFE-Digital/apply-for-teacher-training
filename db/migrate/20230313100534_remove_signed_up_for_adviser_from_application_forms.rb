class RemoveSignedUpForAdviserFromApplicationForms < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :application_forms, :signed_up_for_adviser, :boolean }
  end
end
