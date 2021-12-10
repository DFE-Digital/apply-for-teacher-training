module CourseAPIData
  def course_info_for(course_option)
    {
      recruitment_cycle_year: course_option.course.recruitment_cycle_year,
      provider_code: course_option.course.provider.code,
      site_code: course_option.site.code,
      course_code: course_option.course.code,
      study_mode: course_option.study_mode,
      start_date: course_option.course.start_date.strftime('%Y-%m'),
    }
  end

  def current_course
    { course: course_info_for(application_choice.current_course_option) }
  end
end
