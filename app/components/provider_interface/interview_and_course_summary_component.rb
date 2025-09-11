module ProviderInterface
  class InterviewAndCourseSummaryComponent < ApplicationComponent
    include ViewHelper

    attr_reader :interview, :user_can_change_interview, :application_choice

    def initialize(interview:, user_can_change_interview:)
      @application_choice = interview.application_choice
      @interview = interview
      @user_can_change_interview = user_can_change_interview
    end

    def rows
      [
        {
          key: 'Course',
          value: interview.current_course.name_and_code,
        },
        {
          key: 'Funding type',
          value: Course.human_attribute_name("funding_type.#{interview.current_course.funding_type}"),
        },
        {
          key: 'Interview preferences',
          value: @application_choice.application_form.interview_preferences,
        },
        {
          key: 'Organisation carrying out interview',
          value: interview.provider.name,
        },
        {
          key: 'Address or online meeting details',
          value: interview.location,
        },
        {
          key: 'Additional details',
          value: additional_details,
        },
      ]
    end

    def additional_details
      interview.additional_details.presence || 'None'
    end

    def interview_in_the_past?
      interview.date_and_time < Time.zone.now.beginning_of_day
    end
  end
end
