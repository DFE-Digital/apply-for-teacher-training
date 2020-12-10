class RemoveSatisfactionSurveyFromApplicationForm < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_forms, :satisfaction_survey, :jsonb
  end
end
