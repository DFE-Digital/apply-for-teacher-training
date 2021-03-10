module ProviderInterface
  class OfferSummaryComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :application_choice, :course_option, :conditions

    def initialize(application_choice:, course_option:, conditions:)
      @application_choice = application_choice
      @course_option = course_option
      @conditions = conditions
    end

    def rows
      [
        { key: 'Provider',
          value: course_option.provider.name_and_code,
          action: 'Change',
          change_path: nil },
        { key: 'Course',
          value: course_option.course.name_and_code,
          action: 'Change',
          change_path: nil },
        { key: 'Location',
          value: course_option.site.name_and_address,
          action: 'Change',
          change_path: nil },
        { key: 'Full time or part time',
          value: course_option.study_mode.humanize,
          action: 'Change',
          change_path: nil },
      ]
    end
  end
end
