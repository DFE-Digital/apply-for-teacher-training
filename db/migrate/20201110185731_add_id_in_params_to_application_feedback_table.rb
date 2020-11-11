class AddIdInParamsToApplicationFeedbackTable < ActiveRecord::Migration[6.0]
  def change
    add_column :application_feedback, :id_in_path, :integer
  end
end
