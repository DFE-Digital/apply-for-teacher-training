class ProviderInterface::WorkHistoryAndUnpaidExperienceItemComponent < WorkHistoryItemComponent
  def title
    if item.respond_to?(:role) && item.respond_to?(:working_pattern)
      "#{item.role} - #{working_pattern} #{role_type}"
    elsif item.respond_to?(:reason)
      explained_absence_title
    else
      unexplained_absence_title
    end
  end

  def break?
    item.is_a?(ApplicationWorkHistoryBreak) || item.is_a?(WorkHistoryWithBreaks::BreakPlaceholder)
  end

  def role_type
    '(unpaid)' if item.is_a?(ApplicationVolunteeringExperience)
  end
end
