module CandidateInterface
  class ApplicationFormCourseChoicesComponent < ViewComponent::Base
    def initialize(completed:, number_of_choices:)
      @completed = completed
      @number_of_choices = number_of_choices
    end

    attr_reader :completed, :number_of_choices
    alias completed? completed

    def view_courses_path
      if completed? || choices_are_present?
        candidate_interface_course_choices_review_path
      else
        candidate_interface_course_choices_choose_path
      end
    end

    def maximum_number_of_choices?
      number_of_choices == ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES
    end

    def choices_are_present?
      number_of_choices.positive?
    end
  end
end
