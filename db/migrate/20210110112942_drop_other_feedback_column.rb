class DropOtherFeedbackColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_feedback, :other_feedback, :string
  end
end
