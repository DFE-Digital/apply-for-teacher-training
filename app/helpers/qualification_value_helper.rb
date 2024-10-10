module QualificationValueHelper
  def qualification_text(course_option)
    return if course_option.course.qualifications.nil?

    if course_option.course.undergraduate?
      course_option.course.description
    else
      course_option.course.qualifications.map(&:upcase).join(' with ')
    end
  end
end
