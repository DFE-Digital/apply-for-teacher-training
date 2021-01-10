class BackfillFeedbackColumn < ActiveRecord::Migration[6.0]
  def change
    ApplicationFeedback.all.each { |feedback| feedback.update!(feedback: feedback.other_feedback) }
  end
end
