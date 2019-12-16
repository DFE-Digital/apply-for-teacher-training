module CandidateInterface
  class InterviewPreferencesForm
    include ActiveModel::Model

    DEFAULT_NO_VALUE = I18n.t('application_form.personal_statement.interview_preferences.no_value')

    attr_accessor :any_preferences, :interview_preferences

    validates :any_preferences, presence: true
    validates :interview_preferences, presence: true, if: :any_preferences?
    validates :interview_preferences, word_count: { maximum: 200 }

    class << self
      def build_from_application(application_form)
        new(
          any_preferences: interview_preferences_to_any_preferences(application_form.interview_preferences),
          interview_preferences: application_form.interview_preferences,
        )
      end

      def interview_preferences_to_any_preferences(preferences)
        if preferences.nil?
          nil
        elsif preferences == DEFAULT_NO_VALUE
          'no'
        else
          'yes'
        end
      end
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        interview_preferences: any_preferences? ? interview_preferences : DEFAULT_NO_VALUE,
      )
    end

  private

    def any_preferences?
      any_preferences == 'yes'
    end
  end
end
