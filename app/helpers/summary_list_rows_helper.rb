module SummaryListRowsHelper
  def summary_list_rows(application_choice)
    rows = [
      { key: 'Full name', value: application_choice.application_form.full_name },
      { key: 'Course', value: application_choice.course.name_and_code },
      { key: 'Starting', value: application_choice.course.recruitment_cycle_year },
    ]

    if application_choice.different_offer? || !application_choice.school_placement_auto_selected?
      rows << { key: 'Location', value: application_choice.current_course_option.site.name }
    end

    rows
  end
end
