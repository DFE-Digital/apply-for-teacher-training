class ReasonsForRejectionCountQuery
  THIS_MONTH = 'this_month'.freeze
  BEFORE_THIS_MONTH = 'before_this_month'.freeze

  Result = Struct.new(:all_time, :this_month)

  def reason_counts
    rows = ActiveRecord::Base.connection.exec_query(
      reason_counts_sql,
      'SQL',
      [[nil, Time.zone.now.beginning_of_month]],
    ).to_a

    to_results(rows)
  end

  def sub_reason_counts
    rows = ActiveRecord::Base.connection.exec_query(
      sub_reason_counts_sql,
      'SQL',
      [[nil, Time.zone.now.beginning_of_month]],
    ).to_a

    to_sub_results(rows)
  end

private

  def to_results(rows)
    rows.reduce(Hash.new { |hash, key| hash[key] = Result.new(0, 0) }) { |results, row|
      if row['time_period'] == THIS_MONTH
        results[row['key']].this_month += row['count'].to_i
      end
      results[row['key']].all_time += row['count'].to_i
      results
    }.with_indifferent_access
  end

  def to_sub_results(rows)
    rows.reduce(
      ActiveSupport::HashWithIndifferentAccess.new do |hash, key|
        hash[key] = ActiveSupport::HashWithIndifferentAccess.new do |sub_hash, sub_key|
          sub_hash[sub_key] = Result.new(0, 0)
        end
      end,
    ) do |results, row|
      result = results[row['key']][row['value']]
      if row['time_period'] == THIS_MONTH
        result.this_month += row['count'].to_i
      end
      result.all_time += row['count'].to_i
      results
    end
  end

  def reason_counts_sql
    "
    SELECT reasons.key AS key,
      CASE
        WHEN rejected_at > $1 THEN
          'this_month'
        ELSE
          'before_this_month'
      END AS time_period,
      count(*)
    FROM application_choices,
      jsonb_each_text(structured_rejection_reasons) AS reasons
    WHERE structured_rejection_reasons IS NOT NULL
      AND reasons.value = 'Yes'
    GROUP BY (key, time_period);
    "
  end

  def sub_reason_counts_sql
    "
    SELECT reasons.key AS key,
      sub_reasons.value AS value,
      CASE
        WHEN rejected_at > $1 THEN
          'this_month'
        ELSE
          'before_this_month'
      END AS time_period,
      count(*)
    FROM application_choices,
      jsonb_each(structured_rejection_reasons) AS reasons,
      jsonb_array_elements_text(reasons.value) AS sub_reasons
    WHERE structured_rejection_reasons IS NOT NULL
      AND (reasons.value)::text LIKE '[%'
    GROUP BY (key, sub_reasons.value, time_period);
    "
  end
end
