module ProviderInterface
  class CoursePresentationComponent < ActionView::Component::Base
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def course_option
      application_choice.offered_course_option || application_choice.course_option
    end

    def course
      course_option.course
    end

    def provider_name
      course.provider.name
    end

    def course_name_and_code
      course.name_and_code
    end
  end
end
