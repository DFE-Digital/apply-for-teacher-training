class WorkHistoryAndUnpaidExperienceItemComponent < WorkHistoryItemComponent
  def initialize(item:)
    @item = item
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

  def editable?
    application_form&.editable?
  end

private

  def application_form
    return nil unless @item.is_a?(ApplicationWorkExperience)

    @item.try(:application_form)
  end
end
