class AddSignedUpForAdviserToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :signed_up_for_adviser, :boolean, default: false
  end
end
