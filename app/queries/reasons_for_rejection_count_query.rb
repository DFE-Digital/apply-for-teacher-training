class ReasonsForRejectionCountQuery
  THIS_MONTH = 'this_month'.freeze
  BEFORE_THIS_MONTH = 'before_this_month'.freeze

  Result = Struct.new(:all_time, :this_month, :sub_reasons)

  attr_reader :recruitment_cycle_year

  def initialize(recruitment_cycle_year = RecruitmentCycleTimetable.current_year)
    @recruitment_cycle_year = recruitment_cycle_year
  end

  def grouped_reasons
    query = ApplicationChoice
      .select(
        "sub_reason->'id' as reason",
        select_month,
        'count(*) as total',
      )
      .from(
        'application_choices,
        jsonb_each(structured_rejection_reasons) AS selected_reasons,
        jsonb_array_elements(selected_reasons.value) AS sub_reason',
      )
      .where.not(structured_rejection_reasons: nil)
      .where("jsonb_typeof(selected_reasons.value) = 'array'")
      .where("jsonb_typeof(sub_reason.value) = 'object'")
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .group('reason, time_period')
      .order(total: :desc)

    rows = query.map do |row|
      {
        'key' => row.reason,
        'time_period' => row.time_period,
        'count' => row.total,
      }
    end

    to_results(rows)
  end

  def subgrouped_reasons
    query = ApplicationChoice
      .select(
        "reasons.value::jsonb->'id' as reason",
        "CASE WHEN reasons->'details' IS NOT NULL AND reasons->'details'->'id' IS NOT NULL THEN reasons->'details'->'id' ELSE subreasons->'id' END AS sub_reason",
        select_month,
        'count(*) as total',
      )
      .from(
        "application_choices,
        jsonb_each(structured_rejection_reasons) AS selected_reasons,
        jsonb_array_elements(selected_reasons.value) AS reasons,
        jsonb_array_elements(reasons->'selected_reasons') as subreasons",
      )
      .where.not(structured_rejection_reasons: nil)
      .where("jsonb_typeof(selected_reasons.value) = 'array'")
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .group('reason, sub_reason, time_period')
      .order(total: :desc)

    rows = query.map do |row|
      {
        'key' => row.reason,
        'time_period' => row.time_period,
        'sub_reason' => row.sub_reason,
        'count' => row.total,
      }
    end

    sub_group_results(grouped_reasons, rows)
  end

  def total_structured_reasons_for_rejection(time_period: nil)
    scope = ApplicationChoice
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .where.not(structured_rejection_reasons: nil)

    scope = scope.where(['rejected_at > ?', Time.zone.now.beginning_of_month]) if time_period == :this_month

    scope.count
  end

private

  def select_month
    ActiveRecord::Base.sanitize_sql_for_conditions(
      [
        "CASE WHEN rejected_at > ? THEN 'this_month' ELSE 'before_this_month' END AS time_period",
        Time.zone.now.beginning_of_month,
      ],
    )
  end

  def to_results(rows)
    results_hash = ActiveSupport::HashWithIndifferentAccess.new do |hash, reason|
      hash[reason] = Result.new(
        0, 0, ActiveSupport::HashWithIndifferentAccess.new do |sub_hash, sub_reason|
          sub_hash[sub_reason] = Result.new(0, 0, nil)
        end
      )
    end

    rows.each_with_object(results_hash) do |row, results|
      if row['time_period'] == THIS_MONTH
        results[row['key']].this_month += row['count'].to_i
      end
      results[row['key']].all_time += row['count'].to_i
    end
  end

  def sub_group_results(top_group_results, rows)
    top_group_results.tap do
      rows.each do |row|
        sub_result = top_group_results[row['key']].sub_reasons[row['sub_reason']] = Result.new(0, 0, nil)
        increment_sub_reason_counts(sub_result, row)
      end
    end
  end

  def increment_sub_reason_counts(sub_result, row)
    if row['time_period'] == THIS_MONTH
      sub_result.this_month += row['count'].to_i
    end
    sub_result.all_time += row['count'].to_i
  end
end
