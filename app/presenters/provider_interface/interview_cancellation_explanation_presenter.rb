module ProviderInterface
  class InterviewCancellationExplanationPresenter
    attr_reader :application_choice

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def render?
      number_of_interviews_to_be_cancelled.positive?
    end

    def text
      I18n.t('interview_cancellation.explanation.confirmation_page', count: number_of_interviews_to_be_cancelled)
    end

  private

    def number_of_interviews_to_be_cancelled
      application_choice.interviews.kept.upcoming_not_today.count
    end
  end
end
