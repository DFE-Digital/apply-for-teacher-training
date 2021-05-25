class ValidationErrorSummaryQuery
  ALL_TIME = 'all_time'.freeze
  LAST_WEEK = 'last_week'.freeze
  LAST_MONTH = 'last_month'.freeze

  def initialize(service_name, sort_param = ALL_TIME)
    @service_name = service_name
    @sort_param = sort_param
  end

  def call
    ActiveRecord::Base.connection.exec_query(
      count_sql,
      'SQL',
      [[nil, 1.week.ago.beginning_of_day], [nil, 1.month.ago.beginning_of_day]],
    ).to_a
  end

private

  def count_sql
    "WITH validation_error_counts AS (
      SELECT
        form_object,
        jsonb_object_keys(details) AS attribute,
        CASE
          WHEN created_at > $1 THEN
            1
          ELSE
            0
        END AS incident_last_week,
        CASE
          WHEN created_at > $1 THEN
            user_id
          ELSE
            NULL
        END AS user_id_last_week,
        CASE
          WHEN created_at > $2 THEN
            1
          ELSE
            0
        END AS incident_last_month,
        CASE
          WHEN created_at > $2 THEN
            user_id
          ELSE
            NULL
        END AS user_id_last_month,
        1 AS incident,
        user_id AS user_id
      FROM validation_errors
      WHERE service = '#{@service_name}'
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
    #{order}"
  end

  def order
    case @sort_param
    when LAST_WEEK
      'ORDER BY incidents_last_week DESC'
    when LAST_MONTH
      'ORDER BY incidents_last_month DESC'
    else
      'ORDER BY incidents_all_time DESC'
    end
  end
end
