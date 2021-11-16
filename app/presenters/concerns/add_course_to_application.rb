module AddCourseToApplication
  extend ActiveSupport::Concern

  def schema
    super.merge!({
      course: {
        id: application_choice.course.id,
        name: application_choice.course.name,
      }
    })
  end
end
