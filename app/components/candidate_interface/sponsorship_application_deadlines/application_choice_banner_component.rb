module CandidateInterface
  module SponsorshipApplicationDeadlines
    class ApplicationChoiceBannerComponent < ViewComponent::Base
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def render?
        application_choice.unsubmitted? &&
          application_form.requires_visa_sponsorship? &&
          course.visa_sponsorship_application_deadline_at.present? &&
          course.visa_sponsorship_application_deadline_at.between?(Time.zone.now, 20.days.from_now)
      end

      def count_down
        (course.visa_sponsorship_application_deadline_at.to_datetime - Time.zone.now.to_datetime).to_i
      end

      def deadline_at
        course.visa_sponsorship_application_deadline_at.to_datetime.to_fs(:govuk_time)
      end

    private

      def course
        @course ||= application_choice.course
      end

      def application_form
        @application_form ||= application_choice.application_form
      end
    end
  end
end
