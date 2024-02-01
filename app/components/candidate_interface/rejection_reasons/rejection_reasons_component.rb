module CandidateInterface
  module RejectionReasons
    class RejectionReasonsComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :application_choice

      def initialize(application_choice:, render_link_to_find_when_rejected_on_qualifications: false)
        @application_choice = application_choice
        @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
      end

      def link_to_find_when_rejected_on_qualifications
        link = govuk_link_to(
          'Find postgraduate teacher training courses',
          "#{@application_choice.course.find_url}#section-entry",
        )

        "View the course requirements on #{link}.".html_safe
      end

      def reasons
        ::RejectionReasons.new(application_choice.structured_rejection_reasons)
      end

      def render_link_to_find?(reason)
        reason.id == 'qualifications' && @render_link_to_find_when_rejected_on_qualifications
      end
    end
  end
end
