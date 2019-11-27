class AddVolunteeringExperienceToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :volunteering_experience, :boolean
  end
end
