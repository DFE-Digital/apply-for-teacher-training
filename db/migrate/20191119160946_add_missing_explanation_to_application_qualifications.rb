class AddMissingExplanationToApplicationQualifications < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :missing_explanation, :text, limit: 1000
  end
end
