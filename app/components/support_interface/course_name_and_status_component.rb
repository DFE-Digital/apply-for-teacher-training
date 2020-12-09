module SupportInterface
  class CourseNameAndStatusComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
