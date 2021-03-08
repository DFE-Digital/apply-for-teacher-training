module ProviderInterface
  class SelectCourseComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :form_object, :form_path, :page_title, :courses

    def initialize(form_object:, form_path:, courses:, page_title: 'Select course')
      @form_object = form_object
      @form_path = form_path
      @courses = courses
      @page_title = page_title
    end
  end
end
