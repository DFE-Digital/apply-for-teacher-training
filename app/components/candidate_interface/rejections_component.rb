##
# This component class supports the rendering of all the various formats of reasons for rejection.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/app_concepts/reasons-for-rejection.md
#
module CandidateInterface
  class RejectionsComponent < ApplicationComponent
    attr_reader :application_choice, :render_link_to_find_when_rejected_on_qualifications

    def initialize(application_choice:, render_link_to_find_when_rejected_on_qualifications: false, feedback_button: false)
      @application_choice = application_choice
      @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
      @feedback_button = feedback_button
    end

    def render_rejection_feedback_survey_button
      return unless @feedback_button

      render RejectionReasons::RejectionFeedbackSurveyComponent.new(application_choice:)
    end

    def component_for_rejection_reasons_type
      case @application_choice.rejection_reasons_type
      when 'rejection_reasons', 'vendor_api_rejection_reasons'
        CandidateInterface::RejectionReasons::RejectionReasonsComponent.new(**structured_rejection_reasons_attrs)
      when 'reasons_for_rejection'
        CandidateInterface::RejectionReasons::ReasonsForRejectionComponent.new(**structured_rejection_reasons_attrs)
      else
        ::RejectionReasons::RejectionReasonComponent.new(application_choice:)
      end
    end

    def structured_rejection_reasons_attrs
      { application_choice:, render_link_to_find_when_rejected_on_qualifications: }
    end
  end
end
