module CandidateInterface
  class ApplyAgainAddAnotherCourseComponent < ViewComponent::Base
    attr_accessor :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def number_of_courses_remaining
      "You can add #{pluralize(@application_form.choices_left_to_make, 'more course')}"
    end

    def add_another_course_button
      govuk_button_link_to t('application_form.courses.another.button'), candidate_interface_course_choices_choose_path, secondary: true
    end
  end
end
