class PerformanceStatistics
  QUERY = "
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
      COUNT(*) AS total_non_dfe_sign_ups,
      SUM(CASE WHEN candidate_forms = 0 THEN 1 ELSE 0 END) AS candidates_signed_up_but_not_signed_in,
      SUM(CASE WHEN candidate_forms > 0 AND candidate_started_form_count = 0 THEN 1 ELSE 0 END) AS candidates_signed_in_but_not_entered_data,
      SUM(CASE WHEN candidate_started_form_count > 0 AND candidate_submitted_form_count = 0 THEN 1 ELSE 0 END) AS candidates_with_unsubmitted_forms,
      SUM(CASE WHEN candidate_submitted_form_count > 0 THEN 1 ELSE 0 END) AS candidates_with_submitted_forms
  FROM
      raw_data".freeze

  def [](key)
    results[key.to_s]
  end

private

  def results
    @results ||= ActiveRecord::Base.connection.execute(QUERY)[0]
  end
end
