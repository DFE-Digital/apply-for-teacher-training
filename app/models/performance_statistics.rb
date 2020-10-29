class PerformanceStatistics
  attr_reader :year

  def initialize(year)
    @year = year
  end

  def candidate_query
    year_clause = year ? "AND f.recruitment_cycle_year = #{year}" : ''

    <<-SQL
      WITH raw_data AS (
          SELECT
              c.id,
              f.id,
              f.phase,
              COUNT(f.id) FILTER (WHERE f.id IS NOT NULL) application_forms,
              COUNT(ch.id) FILTER (WHERE f.id IS NOT NULL) application_choices,
              CASE
                WHEN f.id IS NULL THEN ARRAY['-1', 'never_signed_in']
                WHEN ARRAY_AGG(DISTINCT ch.status) IN ('{NULL}', '{unsubmitted}') AND DATE_TRUNC('second', f.updated_at) = DATE_TRUNC('second', f.created_at) THEN ARRAY['0', 'unsubmitted_not_started_form']
                WHEN ARRAY_AGG(DISTINCT ch.status) IN ('{NULL}', '{unsubmitted}') AND DATE_TRUNC('second', f.updated_at) <> DATE_TRUNC('second', f.created_at) THEN ARRAY['1', 'unsubmitted_in_progress']
                WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['4', 'awaiting_provider_decisions']
                WHEN 'offer' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['6', 'awaiting_candidate_response']
                WHEN 'recruited' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['8', 'recruited']
                WHEN 'pending_conditions' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['7', 'pending_conditions']
                WHEN 'offer_deferred' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['10', 'offer_deferred']
                WHEN 'rejected' = ANY(ARRAY_AGG(ch.status)) AND true = ANY(ARRAY_AGG(ch.rejected_by_default)) THEN ARRAY['11', 'rejected_by_default']
                WHEN #{ended_without_success_sql} = '{}' THEN ARRAY['5', 'ended_without_success']
                ELSE ARRAY['10', 'unknown_state']
              END status
          FROM
              application_forms f
          FULL OUTER JOIN
              candidates c ON f.candidate_id = c.id
          LEFT JOIN
              application_choices ch ON ch.application_form_id = f.id
          WHERE
              NOT c.hide_in_reporting
              #{year_clause}
          GROUP BY
              c.id, f.id, f.phase
      )
      SELECT
          raw_data.status[2],
          raw_data.phase,
          COUNT(*)
      FROM
          raw_data
      GROUP BY
          raw_data.status, raw_data.phase
      ORDER BY
          raw_data.status[1]
    SQL
  end

  def ended_without_success_sql
    sql = 'ARRAY_AGG(DISTINCT ch.status)'

    ApplicationStateChange::UNSUCCESSFUL_END_STATES.each do |state|
      sql = "ARRAY_REMOVE(#{sql}, '#{state}')"
    end

    sql
  end

  def [](key)
    candidate_status_counts
      .select { |x| x['status'] == key.to_s }
      .map { |row| row['count'] }
      .sum
  end

  def total_candidate_count(only: nil, except: [], phase: nil)
    candidate_status_counts
      .select { |row| only.nil? || row['status'].to_sym.in?(only) }
      .select { |row| phase.nil? ||  row['phase'].to_sym == phase.to_sym}
      .reject { |row| row['status'].to_sym.in?(except) }
      .map { |row| row['count'] }
      .sum
  end

  def candidate_status_counts
    @candidate_status_counts ||= ActiveRecord::Base
      .connection
      .execute(candidate_query)
      .to_a
  end

  def candidate_status_total_counts
    candidate_status_counts.group_by { |row| row['status'] }.map do |status, rows|
      { 'status' => status, 'count' => rows.map { |r| r['count'] }.sum }
    end
  end

  def total_submitted_count
    total_candidate_count(except: %i[never_signed_in unsubmitted_not_started_form unsubmitted_in_progress])
  end

  def apply_again_submitted_count
    total_candidate_count(except: %i[never_signed_in unsubmitted_not_started_form unsubmitted_in_progress], phase: :apply_2)
  end

  def ended_without_success_count
    total_candidate_count(only: %i[rejected_by_default ended_without_success])
  end

  def accepted_offer_count
    total_candidate_count(only: %i[pending_conditions recruited offer_deferred])
  end

  def apply_again_accepted_offer_count
    total_candidate_count(only: %i[pending_conditions recruited offer_deferred], phase: :apply_2)
  end

  def rejected_by_default_count
    total_candidate_count(only: %i[rejected_by_default])
  end

  def percentage_of_providers_onboarded
    @percentage_of_providers_onboarded ||= begin
      counts = Provider.group(:sync_courses).count
      "#{(counts[true] * 100) / (counts[true] + counts[false])}%"
    end
  end
end
