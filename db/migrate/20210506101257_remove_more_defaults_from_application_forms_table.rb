class RemoveMoreDefaultsFromApplicationFormsTable < ActiveRecord::Migration[6.1]
  def change
    change_column_default :application_forms, :safeguarding_issues_completed, from: false, to: nil
    change_column_default :application_forms, :interview_preferences_completed, from: false, to: nil
  end
end
