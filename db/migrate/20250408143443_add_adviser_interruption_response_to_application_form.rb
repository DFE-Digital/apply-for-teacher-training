class AddAdviserInterruptionResponseToApplicationForm < ActiveRecord::Migration[8.0]
  def change
    add_column :application_forms, :adviser_interruption_response, :boolean, null: true
  end
end
