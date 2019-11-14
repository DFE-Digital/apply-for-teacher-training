class AddVolunteeringCompletedToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :volunteering_completed, :boolean, default: false, null: false
  end
end
