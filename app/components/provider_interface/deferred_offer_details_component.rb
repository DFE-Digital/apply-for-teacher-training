module ProviderInterface
  class DeferredOfferDetailsComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:, course_option: nil)
      @application_choice = application_choice
      @course_option = course_option
    end

    def rows
      [
        {
          key: 'Provider',
          value: course_option.provider.name,
        },
        {
          key: 'Course',
          value: course_option.course.name_and_code,
        },
        {
          key: 'Full time or part time',
          value: course_option.study_mode.humanize,
        },
        {
          key: location_key,
          value: course_option.site.name_and_address,
        },
      ]
    end

  private

    def course_option
      @course_option || @application_choice.current_course_option
    end

    def location_key
      if @application_choice.school_placement_auto_selected?
        t('school_placements.auto_selected')
      else
        t('school_placements.selected_by_candidate')
      end
    end
  end
end
