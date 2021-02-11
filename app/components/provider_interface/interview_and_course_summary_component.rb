module ProviderInterface
  class InterviewAndCourseSummaryComponent < ViewComponent::Base
    attr_reader :interview, :application_choice

    def initialize(interview:)
      @application_choice = interview.application_choice
      @interview = interview
    end

    def rows
      [
        {
          key: 'Course',
          value: interview.offered_course.name,
        },
        {
          key: 'Funding type',
          value: Course.human_attribute_name("funding_type.#{interview.offered_course.funding_type}"),
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
          value: interview.additional_details,
        },
      ]
    end
  end
end
