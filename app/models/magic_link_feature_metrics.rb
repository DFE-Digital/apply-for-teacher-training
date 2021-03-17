class MagicLinkFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def average_magic_link_requests_upto(
    timestamp,
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    records = ApplicationForm
      .apply_1
      .select(
        'count(DISTINCT audits.id) as audit_count',
        'count(DISTINCT authentication_tokens.id) as token_count',
      )
      .joins(:application_choices)
      .joins("LEFT OUTER JOIN audits ON audits.auditable_id = application_forms.candidate_id AND audits.auditable_type = 'Candidate' AND audits.action = 'update' AND audits.audited_changes#>>'{magic_link_token, 1}' IS NOT NULL AND audits.created_at <= application_choices.#{timestamp}")
      .joins("LEFT OUTER JOIN authentication_tokens ON authentication_tokens.user_id = application_forms.candidate_id AND authentication_tokens.user_type = 'Candidate' AND authentication_tokens.created_at <= application_choices.#{timestamp}")
      .where("application_choices.#{timestamp} BETWEEN ? AND ?", start_time, end_time)
      .group('application_forms.id')
    counts = records.map { |record| record.audit_count + record.token_count }
    return 'n/a' if counts.empty?

    number_with_precision(
      counts.sum.to_f / counts.size,
      precision: 1,
      strip_insignificant_zeros: true,
    )
  end
end
