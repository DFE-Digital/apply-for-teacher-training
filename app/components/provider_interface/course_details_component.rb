module ProviderInterface
  class CourseDetailsComponent < ChangeCourseDetailsComponent
    def rows
      [
        { key: 'Training provider', value: provider_name },
        { key: 'Course', value: course_name_and_code },
        { key: 'Cycle', value: cycle },
        { key: 'Full time or part time', value: study_mode },
        location_row,
        { key: 'Accredited body', value: accredited_body },
        { key: 'Qualification', value: qualification },
        { key: 'Funding type', value: funding_type },
      ].compact_blank
    end

  private

    def location_row
      return {} if @application_choice.school_placement_auto_selected?

      { key: t('school_placements.location'), value: preferred_location }
    end
  end
end
