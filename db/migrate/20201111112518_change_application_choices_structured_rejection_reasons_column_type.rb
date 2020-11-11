class ChangeApplicationChoicesStructuredRejectionReasonsColumnType < ActiveRecord::Migration[6.0]
  def change
    change_column :application_choices, :structured_rejection_reasons, :jsonb, using: 'structured_rejection_reasons::text::jsonb'
  end
end
