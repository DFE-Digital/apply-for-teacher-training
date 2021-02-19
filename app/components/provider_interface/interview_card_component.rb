module ProviderInterface
  class InterviewCardComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :interview, :application_choice

    def initialize(interview:)
      @interview = interview
      @application_choice = interview.application_choice
    end

    def candidate_name
      application_choice.application_form.full_name
    end

    delegate :date, to: :interview

    def time
      interview.date_and_time.to_s(:govuk_time)
    end

    def preferences
      'Has interview preferences' if application_choice.application_form.interview_preferences.present?
    end
  end
end
