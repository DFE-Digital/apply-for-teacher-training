module AddCourseToApplication
  extend ActiveSupport::Concern
  VERSION = '1.3'

  def schema
    return super unless version >= VERSION

    super.merge!({
      course: {
        id: application_choice.course.id,
        name: application_choice.course.name,
      }
    })
  end
end
