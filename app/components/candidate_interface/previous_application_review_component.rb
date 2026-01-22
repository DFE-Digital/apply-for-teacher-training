module CandidateInterface
  class PreviousApplicationReviewComponent < ViewComponent::Base
    include CourseFeeRowHelper

    attr_reader :application_choice
    delegate :unsubmitted?,
             :current_course,
             :current_course_option,
             to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def status_tag
      ApplicationStatusTagComponent.new(application_choice:, display_info_text: false)
    end

    def course_link
      if current_course.in_current_recruitment_cycle?
        govuk_link_to(current_course.name_and_code, current_course.find_url)
      else
        current_course.name_and_code
      end
    end

    def fee_uk
      domestic_fee(current_course)
    end

    def fee_international
      international_fee(current_course)
    end

    def qualifications
      current_course.qualifications_to_s
    end

    def course_length
      DisplayCourseLength.call(course_length: current_course.course_length)
    end

    def study_mode
      current_course_option.study_mode.humanize.to_s
    end

    def personal_statement
      PersonalStatementSummaryComponent.new(application_choice:)
    end

    def provider
      application_choice.current_provider
    end
  end
end
