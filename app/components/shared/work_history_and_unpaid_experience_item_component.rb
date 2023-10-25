class WorkHistoryAndUnpaidExperienceItemComponent < WorkHistoryItemComponent
  def initialize(item:, editable: false)
    @item = item
    @editable = editable
  end

  def title
    if item.respond_to?(:role) && item.respond_to?(:working_pattern)
      "#{item.role} - #{working_pattern} #{role_type}"
    elsif item.respond_to?(:reason)
      explained_absence_title
    else
      unexplained_absence_title
    end
  end

  def unexplained_break?
    item.is_a?(WorkHistoryWithBreaks::BreakPlaceholder)
  end

  def role_type
    '(unpaid)' if item.is_a?(ApplicationVolunteeringExperience)
  end

  def edit_path
    if item.is_a?(ApplicationWorkExperience)
      support_interface_application_form_edit_job_path(application_form, @item)
    elsif item.is_a?(ApplicationVolunteeringExperience)
      support_interface_application_form_edit_volunteering_role_path(application_form, @item)
    end
  end

private

  def application_form
    return nil unless @item.is_a?(ApplicationWorkExperience) || @item.is_a?(ApplicationVolunteeringExperience)

    @item.try(:application_form)
  end
end
