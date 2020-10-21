class AddSatisfactionLevel < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :feedback_satisfaction_level, :string
    add_column :application_forms, :feedback_suggestions, :text
  end
end
