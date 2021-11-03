class ReasonsForRejectionCountQuery
  THIS_MONTH = 'this_month'.freeze
  BEFORE_THIS_MONTH = 'before_this_month'.freeze

  Result = Struct.new(:all_time, :this_month, :sub_reasons)

  attr_reader :recruitment_cycle_year

  def initialize(recruitment_cycle_year = RecruitmentCycle.current_year)
    @recruitment_cycle_year = recruitment_cycle_year
  end

  def total_structured_reasons_for_rejection(time_period: nil)
    scope = ApplicationChoice
      .where(current_recruitment_cycle_year: recruitment_cycle_year)
      .where.not(structured_rejection_reasons: nil)

    scope = scope.where(['rejected_at > ?', Time.zone.now.beginning_of_month]) if time_period == :this_month

    scope.count
  end

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

  SUBREASONS_TO_TOP_LEVEL_REASONS = {
    candidate_behaviour_what_did_the_candidate_do: :candidate_behaviour_y_n,
    quality_of_application_which_parts_needed_improvement: :quality_of_application_y_n,
    qualifications_which_qualifications: :qualifications_y_n,
    honesty_and_professionalism_concerns: :honesty_and_professionalism_y_n,
    safeguarding_concerns: :safeguarding_y_n,
  }.with_indifferent_access
  TOP_LEVEL_REASONS_TO_SUB_REASONS = SUBREASONS_TO_TOP_LEVEL_REASONS.map { |k, v| [v, k] }.to_h

  SUBREASON_VALUES = {
    qualifications_y_n: %i[no_maths_gcse no_english_gcse no_science_gcse no_degree other],
    candidate_behaviour_y_n: %i[didnt_reply_to_interview_offer didnt_attend_interview other],
    quality_of_application_y_n: %i[personal_statement subject_knowledge other],
    honesty_and_professionalism_y_n: %i[information_false_or_inaccurate plagiarism references other],
    safeguarding_y_n: %i[candidate_disclosed_information vetting_disclosed_information other],
  }.freeze

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

  def add_sub_results(results, rows)
    rows.each do |row|
      result = result_for_row(results, row)
      sub_result = sub_result_for_row(result, row)
      increment_sub_reason_counts(sub_result, row)
    end
    fill_missing_counts(results)
    results
  end

  def fill_missing_counts(results)
    SUBREASON_VALUES.each do |reason, sub_reasons|
      sub_reasons.each { |sub_reason| results[reason].sub_reasons[sub_reason] }
    end
  end

  def result_for_row(results, row)
    results[SUBREASONS_TO_TOP_LEVEL_REASONS[row['key']]]
  end

  def sub_result_for_row(result, row)
    result.sub_reasons[row['value']]
  end

  def increment_sub_reason_counts(sub_result, row)
    if row['time_period'] == THIS_MONTH
      sub_result.this_month += row['count'].to_i
    end
    sub_result.all_time += row['count'].to_i
  end

  def reason_counts_sql
    "
    SELECT reasons.key AS key,
      CASE
        WHEN rejected_at > $1 THEN
          '#{THIS_MONTH}'
        ELSE
          '#{BEFORE_THIS_MONTH}'
      END AS time_period,
      count(*)
    FROM application_choices,
      jsonb_each_text(structured_rejection_reasons) AS reasons
    WHERE structured_rejection_reasons IS NOT NULL
      AND reasons.value = 'Yes'
      AND current_recruitment_cycle_year = '#{recruitment_cycle_year}'
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
          '#{THIS_MONTH}'
        ELSE
          '#{BEFORE_THIS_MONTH}'
      END AS time_period,
      count(*)
    FROM application_choices,
      jsonb_each(structured_rejection_reasons) AS reasons,
      jsonb_array_elements_text(reasons.value) AS sub_reasons
    WHERE structured_rejection_reasons IS NOT NULL
      AND jsonb_typeof(reasons.value) = 'array'
      AND current_recruitment_cycle_year = '#{recruitment_cycle_year}'
    GROUP BY (key, sub_reasons.value, time_period);
    "
  end
end
