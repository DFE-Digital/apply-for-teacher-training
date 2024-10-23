class GetInactiveApplicationsFromPastDay
  def self.call(single: true)
    ApplicationForm.current_cycle.joins(:application_choices)
      .joins(:candidate).merge(Candidate.for_transaction_emails)
      .select('application_forms.id')
      .group('application_forms.id')
      .having(single ? 'COUNT(application_choices) = 1' : 'COUNT(application_choices) > 1')
      .where(application_choices: { status: :inactive })
      .where('application_choices.inactive_at > ? AND application_choices.inactive_at <= ?', 1.day.ago, Time.zone.now)
  end
end
