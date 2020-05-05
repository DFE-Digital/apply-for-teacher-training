module ProviderInterface
  class CourseDetailsComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :provider, :course, :cycle, :preferred_location, :study_mode

    def initialize(application_choice:)
      @application_choice = application_choice
      @provider = application_choice.provider.name_and_code
      @course = application_choice.course.name_and_code
      @cycle = application_choice.course.recruitment_cycle_year
      @preferred_location = application_choice.site.name_and_code
      @study_mode = application_choice.course_option.study_mode.humanize
    end

    def accredited_body
      accredited_body = @application_choice.course.accredited_provider
      accredited_body.present? ? accredited_body.name_and_code : provider
    end
  end
end
