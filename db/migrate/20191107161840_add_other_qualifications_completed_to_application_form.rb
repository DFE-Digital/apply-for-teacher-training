class AddOtherQualificationsCompletedToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :other_qualifications_completed, :boolean, default: false, null: false
  end
end
