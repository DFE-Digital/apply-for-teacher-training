class RemoveUnusedApplicationFeedbackBooleansAndAddFeedbackColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_feedback, :does_not_understand_section, :boolean
    remove_column :application_feedback, :need_more_information, :boolean
    remove_column :application_feedback, :answer_does_not_fit_format, :boolean
    add_column :application_feedback, :feedback, :string
  end
end
