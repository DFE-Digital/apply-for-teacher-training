module CandidateInterface
  module SponsorshipApplicationDeadlines
    class ApplicationsDashboardBannerComponent < ViewComponent::Base
      attr_reader :application_form
      def initialize(application_form:)
        @application_form = application_form
      end

      def render?
        FeatureFlag.active?(:early_application_deadlines_for_candidates_with_visa_sponsorship) &&
          application_form.right_to_work_or_study_no? &&
          choices.present?
      end

      def course_name(choice)
        "#{choice.course.name_and_code} at #{choice.course.provider.name}"
      end

      def count_down(choice)
        (choice.course.visa_sponsorship_application_deadline_at.to_datetime - Time.zone.now.to_datetime).to_i
      end

      def deadline_at(choice)
        choice.course.visa_sponsorship_application_deadline_at.to_datetime.to_fs(:govuk_time)
      end

      def choices
        @choices ||= application_form
                       .application_choices
                       .unsubmitted
                       .joins(:course)
                       .where('courses.visa_sponsorship_application_deadline_at' => Time.zone.now..20.days.from_now)
                       .order('courses.visa_sponsorship_application_deadline_at')
      end
    end
  end
end
