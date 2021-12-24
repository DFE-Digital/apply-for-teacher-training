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
          ActiveRecord::Base.connection.execute(candidate_query_by_status(phase)).to_a.to_h { |h| [h['status'], h['count']] }
        else
          application_choices.where('application_forms.phase' => phase).group(:status).count
        end
      end
    end
  end
end
