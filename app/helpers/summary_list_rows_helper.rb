module SummaryListRowsHelper
  def summary_list_rows(application_choice)
    location_key = if application_choice.different_offer?
                     t('school_placements.preferred.changed')
                   elsif application_choice.school_placement_auto_selected?
                     t('school_placements.auto_selected')
                   else
                     t('school_placements.selected_by_candidate')
                   end

    summary_list_rows = [
      { key: 'Full name', value: application_choice.application_form.full_name },
      { key: 'Course', value: application_choice.course.name_and_code },
      { key: 'Starting', value: application_choice.course.recruitment_cycle_year },
    ]
    if application_choice.different_offer?
      summary_list_rows << { key: location_key, value: application_choice.site.name }
    end
    summary_list_rows
  end
end
