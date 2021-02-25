module ProviderInterface
  class ChangeCourseComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :form_object, :application_choice, :courses

    def initialize(form_object:, application_choice:, courses:)
      @form_object = form_object
      @application_choice = application_choice
      @courses = courses
    end

    def recruitment_cycle_year
      application_choice.offered_course.recruitment_cycle_year # same year as application
    end

    def page_title
      'Select course'
    end

    def next_step_url
      request.params[:step] = form_object.step
      request.params
    end

    def next_step_method
      :get
    end
  end
end
