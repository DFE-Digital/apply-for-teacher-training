module Publications
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
          tally_application_choices_by_candidate(phase: phase)
        else
          tally_individual_application_choices(phase: phase)
        end
      end

      def tally_individual_application_choices(phase:)
        ApplicationChoice.joins(application_form: :candidate)
          .where('application_forms.phase' => phase, 'application_choices.current_recruitment_cycle_year' => RecruitmentCycle.current_year)
          .where('candidates.hide_in_reporting IS NOT true')
          .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
          .group(:status).count
      end

      def tally_application_choices_by_candidate(phase:)
        cycle = RecruitmentCycle.current_year

        without_subsequent_applications_query = "AND (
                                                    NOT EXISTS (
                                                      SELECT 1
                                                      FROM application_forms
                                                      AS subsequent_application_forms
                                                      WHERE application_forms.id = subsequent_application_forms.previous_application_form_id
                                                    )
                                                  )"

        query = "SELECT COUNT(application_choices_with_minimum_statuses.id), application_choices_with_minimum_statuses.status
                  FROM (
                    SELECT application_choices.id as id,
                           application_choices.status as status,
                           ROW_NUMBER() OVER (
                            PARTITION BY application_forms.id
                            ORDER BY
                            CASE application_choices.status
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
                          INNER JOIN candidates
                            ON application_forms.candidate_id = candidates.id
                            WHERE application_choices.current_recruitment_cycle_year = #{cycle}
                            AND candidates.hide_in_reporting IS NOT TRUE
                            AND application_forms.phase = '#{phase}'
                            #{without_subsequent_applications_query}
                          ) AS application_choices_with_minimum_statuses
                  WHERE application_choices_with_minimum_statuses.row_number = 1
                  GROUP BY status"

        ActiveRecord::Base
          .connection
          .execute(query)
          .to_a
          .map do |hash|
            [hash['status'], hash['count']]
          end.to_h
      end
    end
  end
end
