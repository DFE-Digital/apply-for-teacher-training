module CandidateInterface
  class ApplicationReviewAndSubmitComponent < ApplicationComponent
    include ApplicationHelper

    attr_reader :application_choice, :application_choice_submission
    delegate :errors, to: :application_choice_submission
    delegate :unsubmitted?, :current_course, :current_course_option, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
      @application_choice_submission = CandidateInterface::ApplicationChoiceSubmission.new(application_choice:)
    end

    def render?
      unsubmitted?
    end

    def application_can_submit?
      application_choice_submission.valid?
    end

    def review_path
      ReviewInterruptionPathDecider.decide_path(application_choice)
    end

  private

    def application_form
      @application_form ||= application_choice.application_form
    end
  end
end
