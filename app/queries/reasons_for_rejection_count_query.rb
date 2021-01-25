class ReasonsForRejectionCountQuery
  THIS_MONTH = 'this_month'.freeze
  BEFORE_THIS_MONTH = 'before_this_month'.freeze

  Result = Struct.new(:all_time, :this_month, :sub_reasons)

  def reason_counts
    rows = ActiveRecord::Base.connection.exec_query(
      reason_counts_sql,
      'SQL',
      [[nil, Time.zone.now.beginning_of_month]],
    ).to_a

    to_results(rows)
  end

  def sub_reason_counts
    results = reason_counts

    rows = ActiveRecord::Base.connection.exec_query(
      sub_reason_counts_sql,
      'SQL',
      [[nil, Time.zone.now.beginning_of_month]],
    ).to_a

    add_sub_results(results, rows)
  end

private

  MAPPING = {
    candidate_behaviour_what_did_the_candidate_do: :candidate_behaviour_y_n,
    quality_of_application_which_parts_needed_improvement: :quality_of_application_y_n,
    qualifications_which_qualifications: :qualifications_y_n,
    honesty_and_professionalism_concerns: :honesty_and_professionalism_y_n,
    safeguarding_concerns: :safeguarding_y_n,
  }.with_indifferent_access

  def to_results(rows)
    rows.reduce(ActiveSupport::HashWithIndifferentAccess.new { |hash, key| hash[key] = Result.new(0, 0, ActiveSupport::HashWithIndifferentAccess.new { |hash, key| hash[key] = Result.new(0, 0, nil) }) }) { |results, row|
      if row['time_period'] == THIS_MONTH
        results[row['key']].this_month += row['count'].to_i
      end
      results[row['key']].all_time += row['count'].to_i
      results
    }.with_indifferent_access
  end

  def add_sub_results(results, rows)
    rows.each do |row|
      result = results[MAPPING[row['key']]]
      sub_result = result.sub_reasons[row['value']]
      if row['time_period'] == THIS_MONTH
        sub_result.this_month += row['count'].to_i
      end
      sub_result.all_time += row['count'].to_i
    end
    results
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
    GROUP BY (key, time_period)
    ORDER BY count(*) DESC;
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
