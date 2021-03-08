module ProviderInterface
  class SelectCourseOptionByLocationComponentPreview < ViewComponent::Preview
    class FormObject
      include ActiveModel::Model

      attr_accessor :course_option_id
    end

    def select_course_option
      form_path = ''
      course_options = CourseOption.limit(10)
      form_object = FormObject.new(course_option_id: course_options.last.id)

      render SelectCourseOptionByLocationComponent.new(form_object: form_object,
                                                       form_path: form_path,
                                                       course_options: course_options)
    end
  end
end
