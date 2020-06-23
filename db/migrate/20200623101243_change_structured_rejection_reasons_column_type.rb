class ChangeStructuredRejectionReasonsColumnType < ActiveRecord::Migration[6.0]
  def change
    change_column :application_choices, :structured_rejection_reasons, :text
  end
end
