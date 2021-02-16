module ProviderInterface
  class InterviewAndCourseSummaryComponent < ViewComponent::Base
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
          value: interview.offered_course.name_and_code,
        },
        {
          key: 'Funding type',
          value: Course.human_attribute_name("funding_type.#{interview.offered_course.funding_type}"),
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
          value: get_additional_details,
        },
      ]
    end

    def get_additional_details
      interview.additional_details.presence || 'None'
    end
  end
end
