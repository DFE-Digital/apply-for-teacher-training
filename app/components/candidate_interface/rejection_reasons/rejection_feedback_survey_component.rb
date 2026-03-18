module CandidateInterface
  class RejectionReasons::RejectionFeedbackSurveyComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def answered?
      feedback.present?
    end

    def feedback_text
      if feedback.helpful?
        I18n.t('rejection_feedback_survey.response.helpful')
      else
        I18n.t('rejection_feedback_survey.response.not_helpful')
      end
    end

    def feedback
      ::RejectionFeedback.find_by(application_choice: application_choice)
    end
  end
end
