module ProviderInterface
  class CheckCourseDetailsComponent < ChangeCourseDetailsComponent
    def rows
      [
        { key: 'Training provider', value: course_option.provider.name, action: { href: change_provider_path } },
        { key: 'Course', value: course_option.course.name_and_code, action: { href: change_course_path } },
        { key: 'Full time or part time', value: course_option.study_mode.humanize, action: { href: change_study_mode_path } },
        { key: location_key, value: course_option.site.name_and_address("\n"), action: { href: change_location_path } },
        { key: 'Accredited body', value: accredited_body },
        { key: 'Qualification', value: qualification_text(course_option) },
        { key: 'Funding type', value: course.funding_type.humanize },
      ]
    end

    def accredited_body
      accredited_body = course_option.course.accredited_provider
      accredited_body.present? ? accredited_body.name : provider_name
    end
  end
end
