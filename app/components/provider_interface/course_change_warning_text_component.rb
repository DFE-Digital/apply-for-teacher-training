module ProviderInterface
  class CourseChangeWarningTextComponent < ApplicationComponent
    attr_reader :application_choice, :wizard

    def initialize(application_choice:, wizard:)
      @application_choice = application_choice
      @wizard = wizard
    end

    def only_location_or_study_mode_change?
      application_choice.course.id == wizard.course_option.course.id &&
        application_choice.provider.id == wizard.course_option.provider.id &&
        (application_choice.site.id != wizard.course_option.site.id || application_choice.course_option.study_mode != wizard.course_option.study_mode)
    end

    def identical_to_existing_course?
      application_choice.current_course_option == wizard.course_option
    end
  end
end
