module SupportInterface
  class ApplicationAddCourseComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end
  end
end
