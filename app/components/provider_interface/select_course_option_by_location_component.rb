module ProviderInterface
  class SelectCourseOptionByLocationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :form_object, :form_path, :course_options, :page_title

    def initialize(form_object:, form_path:, course_options:, page_title: 'Select location')
      @form_object = form_object
      @form_path = form_path
      @course_options = course_options
      @page_title = page_title
    end
  end
end
