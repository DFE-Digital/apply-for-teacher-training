class ValidationErrorSummaryQuery
  COUNT_SQL =
    'SELECT COUNT(*) AS incidents, COUNT(DISTINCT user_id) AS distinct_users
    FROM validation_errors'.freeze
  COUNT_WITH_START_TIME_SQL =
    "#{COUNT_SQL}
    WHERE created_at > $1".freeze

  def call
    {
      last_week: errors_since(1.week.ago),
      last_month: errors_since(1.month.ago),
      all_time: all_errors,
    }
  end

private

  def all_errors
    ActiveRecord::Base.connection.exec_query(COUNT_SQL).first.symbolize_keys
  end

  def errors_since(start_date)
    ActiveRecord::Base.connection.exec_query(
      COUNT_WITH_START_TIME_SQL,
      'SQL',
      [[nil, start_date]],
    ).first.symbolize_keys
  end
end
