module ProviderInterface
  class SelectCourseComponentPreview < ViewComponent::Preview
    class FormObject
      include ActiveModel::Model

      attr_accessor :course_id
    end

    def select_course
      form_path = ''
      courses = Course.limit(10)
      form_object = FormObject.new(course_id: courses.last.id)

      render SelectCourseComponent.new(form_object: form_object,
                                       form_path: form_path,
                                       courses: courses)
    end
  end
end
