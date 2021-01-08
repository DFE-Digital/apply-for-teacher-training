class MagicLinkFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def average_magic_link_requests_upto(
    timestamp,
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    counts = ApplicationForm
      .select('count(DISTINCT audits.id)')
      .joins(:application_choices)
      .joins('LEFT OUTER JOIN audits ON audits.auditable_id = application_forms.candidate_id')
      .where('application_choices.offered_at BETWEEN ? AND ?', start_time, end_time)
      .where(
        'audits.auditable_type': 'Candidate',
        'audits.action': 'update',
      )
      .where("audits.audited_changes#>>'{magic_link_token, 1}' IS NOT NULL")
      .where("audits.created_at < application_choices.#{timestamp}")
      .group('application_forms.id')
      .map(&:count)
    return 'n/a' if counts.empty?

    number_with_precision(
      counts.sum.to_f / counts.size,
      precision: 1,
      strip_insignificant_zeros: true,
    )
  end
end
