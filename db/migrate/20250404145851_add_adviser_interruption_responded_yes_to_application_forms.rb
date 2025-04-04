class AddAdviserInterruptionRespondedYesToApplicationForms < ActiveRecord::Migration[8.0]
  def change
    add_column :application_forms, :adviser_interruption_responded_yes, :boolean, default: nil, null: true
  end
end
