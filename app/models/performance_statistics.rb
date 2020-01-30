class PerformanceStatistics
  CANDIDATE_COUNTS_QUERY = "
  WITH raw_data AS (
      SELECT
          COUNT(c.id) FILTER (WHERE f.id IS NOT NULL) candidate_forms,
          SUM(CASE WHEN f.id IS NOT NULL AND f.created_at < f.updated_at THEN 1 ELSE 0 END) candidate_started_form_count,
          SUM(CASE WHEN f.id IS NOT NULL AND f.submitted_at IS NOT NULL THEN 1 ELSE 0 END) candidate_submitted_form_count
      FROM
          candidates c
      LEFT JOIN
          application_forms f ON f.candidate_id = c.id
      WHERE
          NOT c.hide_in_reporting
      GROUP BY
          c.id
  )
  SELECT
      COUNT(*) AS total_candidate_count,
      SUM(CASE WHEN candidate_forms = 0 THEN 1 ELSE 0 END) AS candidates_signed_up_but_not_signed_in,
      SUM(CASE WHEN candidate_forms > 0 AND candidate_started_form_count = 0 AND candidate_submitted_form_count = 0 THEN 1 ELSE 0 END) AS candidates_signed_in_but_not_entered_data,
      SUM(CASE WHEN candidate_started_form_count > 0 AND candidate_submitted_form_count = 0 THEN 1 ELSE 0 END) AS candidates_with_unsubmitted_forms,
      SUM(CASE WHEN candidate_submitted_form_count > 0 THEN 1 ELSE 0 END) AS candidates_with_submitted_forms
  FROM
      raw_data".freeze

  APPLICATION_FORM_STATUS_COUNTS_QUERY = "
  WITH raw_data AS (
      SELECT
          f.id,
          COUNT(f.id) FILTER (WHERE f.id IS NOT NULL) application_forms,
          COUNT(ch.id) FILTER (WHERE f.id IS NOT NULL) application_choices,
          CASE
            WHEN ARRAY_AGG(DISTINCT ch.status) = '{NULL}' THEN ARRAY['0', 'unsubmitted']
            WHEN ARRAY_AGG(DISTINCT ch.status) = '{unsubmitted}' THEN ARRAY['0', 'unsubmitted']
            WHEN 'awaiting_references' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['1', 'awaiting_references']
            WHEN 'application_complete' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['2', 'waiting_to_be_sent']
            WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['3', 'awaiting_provider_decisions']
            WHEN 'offer' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['5', 'awaiting_candidate_response']
            WHEN 'enrolled' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['8', 'enrolled']
            WHEN 'recruited' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['7', 'recruited']
            WHEN 'pending_conditions' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['6', 'pending_conditions']
            WHEN ARRAY_REMOVE(ARRAY_REMOVE(ARRAY_REMOVE(ARRAY_REMOVE(ARRAY_AGG(DISTINCT ch.status), 'withdrawn'), 'rejected'), 'declined'), 'conditions_not_met') = '{}' THEN ARRAY['4', 'ended_without_success']
            ELSE ARRAY['9', 'unknown_state']
          END status
      FROM
          candidates c
      LEFT JOIN
          application_forms f ON f.candidate_id = c.id
      LEFT JOIN
          application_choices ch ON ch.application_form_id = f.id
      WHERE
          NOT c.hide_in_reporting
      GROUP BY
          f.id
  )
  SELECT
      raw_data.status[2],
      COUNT(*)
  FROM
      raw_data
  GROUP BY
      raw_data.status
  ORDER BY
      raw_data.status[1]".freeze

  def [](key)
    candidate_counts[key.to_s]
  end

  def application_form_status_counts
    @application_form_status_counts ||= ActiveRecord::Base
      .connection
      .execute(APPLICATION_FORM_STATUS_COUNTS_QUERY)
      .to_a
  end

  def application_form_counts_total
    application_form_status_counts.sum { |row| row['count'].to_i }
  end

private

  def candidate_counts
    @candidate_counts ||= ActiveRecord::Base.connection.execute(CANDIDATE_COUNTS_QUERY)[0]
  end
end
