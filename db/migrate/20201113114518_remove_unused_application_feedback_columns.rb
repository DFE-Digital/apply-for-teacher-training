class RemoveUnusedApplicationFeedbackColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_feedback, :section, :boolean
    remove_column :application_feedback, :issues, :boolean
    remove_column :application_feedback, :id_in_path, :integer
  end
end
