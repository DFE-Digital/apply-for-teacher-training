class VendorAPIRequestSummaryQuery
  ALL_TIME = 'all_time'.freeze
  LAST_WEEK = 'last_week'.freeze
  LAST_MONTH = 'last_month'.freeze

  def initialize(sort_param = ALL_TIME)
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
    "WITH vendor_api_request_counts AS (
      SELECT
        request_path,
        jsonb_extract_path_text(jsonb_array_elements(response_body->'errors'), 'error') AS attribute,
        CASE
          WHEN created_at > $1 THEN
            1
          ELSE
            0
        END AS incident_last_week,
        CASE
          WHEN created_at > $1 THEN
            provider_id
          ELSE
            NULL
        END AS provider_id_last_week,
        CASE
          WHEN created_at > $2 THEN
            1
          ELSE
            0
        END AS incident_last_month,
        CASE
          WHEN created_at > $2 THEN
            provider_id
          ELSE
            NULL
        END AS provider_id_last_month,
        1 AS incident,
        provider_id AS provider_id
      FROM vendor_api_requests
      WHERE status_code = 422
    )
    SELECT
      request_path,
      attribute,
      SUM(incident_last_week) AS incidents_last_week,
      COUNT(DISTINCT provider_id_last_week) AS unique_providers_last_week,
      SUM(incident_last_month) AS incidents_last_month,
      COUNT(DISTINCT provider_id_last_month) AS unique_providers_last_month,
      SUM(incident) AS incidents_all_time,
      COUNT(DISTINCT provider_id) AS unique_providers_all_time
    FROM vendor_api_request_counts
    GROUP BY request_path, attribute
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
