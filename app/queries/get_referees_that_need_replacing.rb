class GetRefereesThatNeedReplacing
  def self.call
    ApplicationReference
      .feedback_requested
      .where.not(id: ChaserSent.reference_replacement.select(:chased_id))
      .select(&:feedback_overdue?)
  end
end
