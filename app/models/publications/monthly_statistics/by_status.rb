module Publications
  module MonthlyStatistics
    class ByStatus < Publications::MonthlyStatistics::Base
      def initialize(by_candidate: false)
        @by_candidate = by_candidate
      end

      def table_data
        {
          rows: rows,
          column_totals: column_totals_for(rows),
        }
      end

      def rows
        @rows ||= formatted_counts.map do |status, phases|
          apply_1_count = (phases['apply_1'] || 0)
          apply_again_count = (phases['apply_2'] || 0)
          {
            'Status' => status,
            'First application' => apply_1_count,
            'Apply again' => apply_again_count,
            'Total' => apply_1_count + apply_again_count,
          }
        end
      end

      def formatted_counts
        counts = {
          'Recruited' => { 'apply_1' => 0, 'apply_2' => 0 },
          'Conditions pending' => { 'apply_1' => 0, 'apply_2' => 0 },
          'Deferred' => { 'apply_1' => 0, 'apply_2' => 0 },
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
            when 'pending_conditions'
              counts['Conditions pending'][phase] += count
            when 'offer_deferred'
              counts['Deferred'][phase] += count
            when 'offer'
              counts['Received an offer but not responded'][phase] += count
            when 'recruited'
              counts['Recruited'][phase] += count
            when 'rejected', 'conditions_not_met', 'offer_withdrawn'
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
        if @by_candidate
          ActiveRecord::Base.connection.execute(candidate_query(phase)).to_a.map { |h| [h['status'], h['count']] }.to_h
        else
          application_choices.where('application_forms.phase' => phase).group(:status).count
        end
      end

      def candidate_query(phase)
        <<~SQL
          WITH raw_data AS (
              SELECT
                  c.id,
                  f.id,
                  CASE
                    WHEN 'recruited' = ANY(ARRAY_AGG(ch.status)) THEN 'recruited'
                    WHEN 'pending_conditions' = ANY(ARRAY_AGG(ch.status)) THEN 'pending_conditions'
                    WHEN 'offer_deferred' = ANY(ARRAY_AGG(ch.status)) THEN 'offer_deferred'
                    WHEN 'offer' = ANY(ARRAY_AGG(ch.status)) THEN 'offer'
                    WHEN 'interviewing' = ANY(ARRAY_AGG(ch.status)) THEN 'interviewing'
                    WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(ch.status)) THEN 'awaiting_provider_decision'
                    WHEN 'declined' = ANY(ARRAY_AGG(ch.status)) THEN 'declined'
                    WHEN 'offer_withdrawn' = ANY(ARRAY_AGG(ch.status)) THEN 'offer_withdrawn'
                    WHEN 'conditions_not_met' = ANY(ARRAY_AGG(ch.status)) THEN 'conditions_not_met'
                    WHEN 'rejected' = ANY(ARRAY_AGG(ch.status)) THEN 'rejected'
                    WHEN 'withdrawn' = ANY(ARRAY_AGG(ch.status)) THEN 'withdrawn'
                  END status
                FROM
                  application_forms f
                JOIN
                    candidates c ON f.candidate_id = c.id
                LEFT JOIN
                    application_choices ch ON ch.application_form_id = f.id
                WHERE
                    NOT c.hide_in_reporting
                    AND ch.current_recruitment_cycle_year = #{RecruitmentCycle.current_year}
                    AND f.phase = '#{phase}'
                    AND (
                      NOT EXISTS (
                        SELECT 1
                        FROM application_forms
                        AS subsequent_application_forms
                        WHERE f.id = subsequent_application_forms.previous_application_form_id
                        AND subsequent_application_forms.submitted_at IS NOT NULL
                      )
                    )
                GROUP BY
                    c.id, f.id
          )
          SELECT
              raw_data.status,
              COUNT(*)
          FROM
              raw_data
          GROUP BY
              raw_data.status
        SQL
      end
    end
  end
end
