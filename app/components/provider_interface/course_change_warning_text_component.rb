module ProviderInterface
  class CourseChangeWarningTextComponent < ViewComponent::Base
    attr_reader :application_choice, :wizard

    def initialize(application_choice:, wizard:)
      @application_choice = application_choice
      @wizard = wizard
    end

    def only_location_or_study_mode_change?
      application_choice.course.id == wizard.course_id &&
        application_choice.provider.id == wizard.provider_id &&
        (application_choice.site.id != wizard.location_id || application_choice.course_option.study_mode != wizard.study_mode)
    end
  end
end
