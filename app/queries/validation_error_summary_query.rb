class ValidationErrorSummaryQuery
  COUNT_SQL =
    "WITH validation_error_counts AS (
      SELECT
        form_object,
        jsonb_object_keys(details) AS attribute,
        CASE
          WHEN created_at > date_trunc('day', NOW() - interval '1 week') THEN
            1
          ELSE
            0
        END AS incident_last_week,
        CASE
          WHEN created_at > date_trunc('day', NOW() - interval '1 week') THEN
            user_id
          ELSE
            NULL
        END AS user_id_last_week,
        CASE
          WHEN created_at > date_trunc('day', NOW() - interval '1 month') THEN
            1
          ELSE
            0
        END AS incident_last_month,
        CASE
          WHEN created_at > date_trunc('day', NOW() - interval '1 month') THEN
            user_id
          ELSE
            NULL
        END AS user_id_last_month,
        1 AS incident,
        user_id AS user_id
      FROM validation_errors
    )
    SELECT
      form_object,
      attribute,
      SUM(incident_last_week) AS incidents_last_week,
      COUNT(DISTINCT user_id_last_week) AS unique_users_last_week,
      SUM(incident_last_month) AS incidents_last_month,
      COUNT(DISTINCT user_id_last_month) AS unique_users_last_month,
      SUM(incident) AS incidents_all_time,
      COUNT(DISTINCT user_id) AS unique_users_all_time
    FROM validation_error_counts
    GROUP BY form_object, attribute
    ORDER BY incidents_all_time DESC".freeze

  def call
    ActiveRecord::Base.connection.exec_query(COUNT_SQL).to_a
  end
end
