module ProviderInterface
  class CheckCourseDetailsComponent < ChangeCourseDetailsComponent
    def rows
      [
        { key: 'Training provider', value: course_option.provider.name, action: { href: change_provider_path } },
        { key: 'Course', value: course_option.course.name_and_code, action: { href: change_course_path } },
        { key: 'Full time or part time', value: course_option.study_mode.humanize, action: { href: change_study_mode_path } },
        location_row,
        { key: 'Accredited body', value: accredited_body },
        { key: 'Qualification', value: qualification_text(course_option) },
        { key: 'Funding type', value: course.funding_type.humanize },
      ].compact_blank
    end

    def accredited_body
      accredited_body = course_option.course.accredited_provider
      accredited_body.present? ? accredited_body.name : provider_name
    end
  end
end
