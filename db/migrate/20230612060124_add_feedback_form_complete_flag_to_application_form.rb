class AddFeedbackFormCompleteFlagToApplicationForm < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :feedback_form_complete, :boolean, default: false
  end
end
