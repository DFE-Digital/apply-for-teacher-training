module ProviderInterface
  class CoursePresentationComponent < ActionView::Component::Base
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def provider_name
      @application_choice.provider.name
    end

    def course_name_and_code
      @application_choice.course.name_and_code
    end
  end
end
