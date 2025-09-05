module CandidateInterface
  module RejectionReasons
    class RejectionReasonsComponent < ApplicationComponent
      include ViewHelper

      attr_reader :application_choice

      def initialize(application_choice:, render_link_to_find_when_rejected_on_qualifications: false)
        @application_choice = application_choice
        @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
      end

      def link_to_find_when_rejected_on_qualifications
        link = govuk_link_to(
          t('service_name.find'),
          "#{@application_choice.course.find_url}#section-entry",
        )

        "View the course requirements on #{link}.".html_safe
      end

      def render_link_for_rejection_due_to_non_uk_qualification_and_no_enic
        link = govuk_link_to('Apply for a statement of comparability from UK ENIC', I18n.t('service_name.enic.statement_of_comparability_url'))

        "If you decide to apply again, think about including a statement of comparability from UK ENIC.
        It shows training providers how your qualifications compare to UK ones. <br><br>#{link}<br><br>
        Applications with a statement from UK ENIC are around 28% more likely to receive an offer.".html_safe
      end

      def reasons
        ::RejectionReasons.new(application_choice.structured_rejection_reasons)
      end

      def render_link_to_find?(reason)
        reason.id == 'qualifications' && @render_link_to_find_when_rejected_on_qualifications
      end

      def render_rejection_link_to_enic?(reason)
        return false unless reason.id == 'qualifications' && reason.selected_reasons

        reason.selected_reasons.any? do |nested_reason|
          nested_reason.id == 'unverified_qualifications' && application_form.missing_enic_reference_for_non_uk_qualifications?
        end
      end

    private

      def application_form
        @application_form ||= ApplicationForm.find(application_choice.application_form_id)
      end
    end
  end
end
