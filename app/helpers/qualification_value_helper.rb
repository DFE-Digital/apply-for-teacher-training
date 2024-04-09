module QualificationValueHelper
  def qualification_text(course_option)
    return if course_option.course.qualifications.nil?

    course_option.course.qualifications.map(&:upcase).join(' with ')
  end
end
