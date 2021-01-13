class ReasonsForRejectionFeatureMetrics
  def rejections_due_to(
    reason,
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    raise ArgumentError unless ProviderInterface::ReasonsForRejectionWizard::INITIAL_TOP_LEVEL_QUESTIONS.include?(reason)

    ApplicationChoice
      .rejected
      .where("structured_rejection_reasons->>'#{reason}' = 'Yes'")
      .where('rejected_at BETWEEN ? AND ?', start_time, end_time)
      .count
  end
end
