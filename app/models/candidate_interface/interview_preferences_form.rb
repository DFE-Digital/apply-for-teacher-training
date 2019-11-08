module CandidateInterface
  class InterviewPreferencesForm
    include ActiveModel::Model

    attr_accessor :interview_preferences

    validates :interview_preferences,
              word_count: { maximum: 200 },
              presence: true

    def self.build_from_application(application_form)
      new(
        interview_preferences: application_form.interview_preferences,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        interview_preferences: interview_preferences,
      )
    end
  end
end
