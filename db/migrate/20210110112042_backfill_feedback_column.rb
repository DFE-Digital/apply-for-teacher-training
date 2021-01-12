class BackfillFeedbackColumn < ActiveRecord::Migration[6.0]
  def change
    ApplicationFeedback.all.each { |feedback| feedback.update_column(:feedback, feedback.other_feedback) }
  end
end
