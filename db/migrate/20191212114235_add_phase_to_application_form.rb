class AddPhaseToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :phase, :string, null: false, default: 'apply_1'
  end
end
