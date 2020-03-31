class AddSatisfactionSurveyToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :satisfaction_survey, :jsonb
  end
end
