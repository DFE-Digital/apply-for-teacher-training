module CandidateInterface
  class NewCourseChoiceNeededBannerComponent < ViewComponent::Base
    include ViewHelper

    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      @application_form.course_choices_that_need_replacing.any?
    end
  end
end
