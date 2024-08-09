module CandidateInterface
  class ApplicationReviewAndSubmitComponent < ViewComponent::Base
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
      if short_personal_statement?
        candidate_interface_continuous_applications_course_review_interruption_path(application_choice.id)
      else
        candidate_interface_continuous_applications_course_review_and_submit_path(application_choice.id)
      end
    end

  private

    def short_personal_statement?
      application_choice.application_form.becoming_a_teacher.scan(/\S+/).size < recommended_word_count
    end

    def recommended_word_count
      ApplicationForm::RECOMMENDED_PERSONAL_STATEMENT_WORD_COUNT
    end
  end
end
