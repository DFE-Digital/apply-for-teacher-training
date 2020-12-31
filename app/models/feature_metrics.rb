class FeatureMetrics
  # def time_to_get_references(start_time, end_time = Time.zone.now)
  #   data ||= ActiveRecord::Base
  #     .connection
  #     .select_all(TIME_TO_GET_REFERENCES_SQL % [start_time.iso8601, end_time.iso8601])
  #     .to_a
  #   # times = data.map { |audits| time_to_get_reference_for(audits) }.compact
  #   # times.sum.to_f / time.size
  # end

  def time_to_get_references(start_time, end_time = Time.zone.now)
    references = ApplicationReference.where(
      'id IN (:reference_ids)',
      reference_ids: Audited::Audit
        .select(:auditable_id)
        .where(auditable_type: 'ApplicationReference')
        .where("audited_changes#>>'{feedback_status, 1}' = 'feedback_provided'")
        .where('created_at BETWEEN ? AND ?', start_time, end_time),
    )
    times_to_get = references.map { |reference| time_to_get_for(reference) }.compact
    return nil if times_to_get.blank?

    times_to_get.sum.to_f / times_to_get.size
  end

  # TIME_TO_GET_REFERENCES_SQL = <<~SQL
  #   SELECT auditable_id,
  #     array_agg(ARRAY[audited_changes#>>'{feedback_status, 1}', created_at::text])
  #   FROM audits
  #   WHERE audited_changes#>>'{feedback_status, 1}' IS NOT NULL
  #     AND auditable_id IN (
  #       SELECT auditable_id 
  #       FROM audits
  #       WHERE auditable_type = 'ApplicationReference'
  #       AND audited_changes#>>'{feedback_status, 1}' = 'feedback_provided'
  #       AND created_at BETWEEN '%s' AND '%s'
  #     )
  #   GROUP BY auditable_id;
  # SQL

private

  def time_to_get_for(reference)
    provided_audit = reference.audits.where("audited_changes#>>'{feedback_status, 1}' = 'feedback_provided'").last
    requested_at = reference.requested_at
    provided_at = provided_audit&.created_at
    return nil if requested_at.nil? || provided_at.nil?

    (provided_at - requested_at).to_i / 1.day
  end
end
