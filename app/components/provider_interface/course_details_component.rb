module ProviderInterface
  class CourseDetailsComponent < ChangeCourseDetailsComponent
    def rows
      [
        { key: 'Training provider', value: provider_name_and_code },
        { key: 'Course', value: course_name_and_code },
        { key: 'Cycle', value: cycle },
        { key: 'Full or part time', value: study_mode },
        { key: 'Location', value: preferred_location },
        { key: 'Accredited body', value: accredited_body },
        { key: 'Qualification', value: qualification },
        { key: 'Funding type', value: funding_type },
      ]
    end
  end
end
