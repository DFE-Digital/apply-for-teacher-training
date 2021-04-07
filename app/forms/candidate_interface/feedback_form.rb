module CandidateInterface
  class FeedbackForm
    include ActiveModel::Model

    attr_accessor :satisfaction_level, :suggestions

    def save(application_form)
      return false unless valid?

      application_form.feedback_satisfaction_level = satisfaction_level
      application_form.feedback_suggestions = suggestions
      application_form.save
    end
  end
end
