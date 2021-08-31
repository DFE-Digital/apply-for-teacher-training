class AddNotCompletedExplanationToApplicationQualifications < ActiveRecord::Migration[6.1]
  def change
    add_column :application_qualifications, :not_completed_explanation, :text
    add_column :application_qualifications, :currently_completing_qualification, :boolean
  end
end
