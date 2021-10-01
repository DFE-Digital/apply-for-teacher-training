module MonthlyStatistics
  class ByStatus
    def initialize(by_candidate: false)
      @by_candidate = by_candidate
    end

    def table_data
      {
        rows: rows,
        column_totals: column_totals_for(rows),
      }
    end

  private

    def rows
      @rows ||= formatted_counts.map do |status, phases|
        {
          'Status' => status,
          'First application' => apply_one_count(phases),
          'Apply again' => apply_again_count(phases),
          'Total' => phase_count(phases),
        }
      end
    end

    def column_totals_for(rows)
      _age_group, *statuses = rows.first.keys

      statuses.map do |column_name|
        column_total = rows.inject(0) { |total, hash| total + hash[column_name] }
        column_total
      end
    end

    def formatted_counts
      counts = {
        'Recruited' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Conditions pending' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Received an offer but not responded' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Awaiting provider decisions' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Declined an offer' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Withdrew an application' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Application rejected' => { 'apply_1' => 0, 'apply_2' => 0 },
      }

      combined_application_choice_states_tally = {
        'apply_1' => combined_application_choice_states_tally('apply_1'),
        'apply_2' => combined_application_choice_states_tally('apply_2'),
      }

      combined_application_choice_states_tally.map do |phase, tally|
        tally.map do |status, count|
          case status
          when 'awaiting_provider_decision', 'interviewing'
            counts['Awaiting provider decisions'][phase] += count
          when 'conditions_not_met', 'offer_deferred'
            counts['Conditions pending'][phase] += count
          when 'offer'
            counts['Received an offer but not responded'][phase] += count
          when 'recruited'
            counts['Recruited'][phase] += count
          when 'rejected'
            counts['Application rejected'][phase] += count
          when 'withdrawn'
            counts['Withdrew an application'][phase] += count
          when 'declined'
            counts['Declined an offer'][phase] += count
          end
        end
      end

      counts
    end

    def combined_application_choice_states_tally(phase)
      status_for_choices_tally = tally_application_choices(phase: phase, cycle: RecruitmentCycle.current_year, field: 'status')
      deferral_status_choices_tally = tally_application_choices(phase: phase, cycle: RecruitmentCycle.previous_year, field: 'status_before_deferral')

      format_deferral_status_choices_tally = deferral_status_choices_tally.map do |tally|
        tally['status'] = tally['status_before_deferral']
        tally
      end

      combined_tally = status_for_choices_tally + format_deferral_status_choices_tally

      status_and_count_hash = combined_tally.map do |hash|
        { hash['status'] => hash['count'] }
      end

      status_and_count_hash.each_with_object(Hash.new(0)) do |hash, sum|
        hash.each { |key, value| sum[key] += value }
      end
    end

    def tally_application_choices(phase:, cycle:, field:)
      without_subsequent_applications_query = if @by_candidate
                                                "AND (
                                                  NOT EXISTS (
                                                    SELECT 1
                                                    FROM application_forms
                                                    AS subsequent_application_forms
                                                    WHERE application_forms.id = subsequent_application_forms.previous_application_form_id
                                                  )
                                                )"
                                              else
                                                ''
                                              end

      query = "SELECT COUNT(application_choices_with_minimum_statuses.id), application_choices_with_minimum_statuses.#{field}
                FROM (
                  SELECT application_choices.id as id,
                         application_choices.status_before_deferral as status_before_deferral,
                         application_choices.status as status,
                         ROW_NUMBER() OVER (
                          PARTITION BY application_forms.id
                          ORDER BY
                          CASE application_choices.#{field}
                          WHEN 'recruited' THEN 1
                          WHEN 'pending_conditions' THEN 2
                          WHEN 'conditions_not_met' THEN 2
                          WHEN 'offer' THEN 3
                          WHEN 'awaiting_provider_decision' THEN 4
                          WHEN 'interviewing' THEN 4
                          WHEN 'declined' THEN 5
                          WHEN 'offer_withdrawn' THEN 6
                          WHEN 'withdrawn' THEN 7
                          WHEN 'cancelled' THEN 7
                          WHEN 'rejected' THEN 7
                          ELSE 8
                          END
                        ) AS row_number
                        FROM application_forms
                        INNER JOIN application_choices
                          ON application_choices.application_form_id = application_forms.id
                          WHERE application_forms.recruitment_cycle_year = #{cycle}
                          AND application_forms.phase = '#{phase}'
                          #{without_subsequent_applications_query}
                        ) AS application_choices_with_minimum_statuses
                WHERE application_choices_with_minimum_statuses.row_number = 1
                GROUP BY #{field}"

      ActiveRecord::Base
        .connection
        .execute(query)
        .to_a
    end

    def apply_one_count(phases)
      phases['apply_1'] || 0
    end

    def apply_again_count(phases)
      phases['apply_2'] || 0
    end

    def phase_count(phases)
      apply_one_count(phases) + apply_again_count(phases)
    end
  end
end
