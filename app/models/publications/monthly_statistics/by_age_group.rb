module Publications
  module MonthlyStatistics
    class ByAgeGroup < Publications::MonthlyStatistics::Base
      def table_data
        {
          rows: apply_minimum_value_rule_to_rows(rows),
          column_totals: apply_minimum_value_rule_to_totals(column_totals_for(rows)),
        }
      end

      def rows
        @rows ||= formatted_age_group_query.map do |age_group, statuses|
          {
            'Age group' => age_group,
            'Recruited' => recruited_count(statuses),
            'Conditions pending' => pending_count(statuses),
            'Deferrals' => deferred_count(statuses),
            'Received an offer' => offer_count(statuses),
            'Awaiting provider decisions' => awaiting_decision_count(statuses),
            'Unsuccessful' => unsuccessful_count(statuses),
            'Total' => statuses_count(statuses),
          }
        end
      end

      def formatted_age_group_query
        counts = {
          '21 and under' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '22' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '23' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '24' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '25 to 29' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '30 to 34' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '35 to 39' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '40 to 44' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '45 to 49' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '50 to 54' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '55 to 59' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '60 to 64' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
          '65 and over' => {
            'recruited' => 0,
            'pending_conditions' => 0,
            'offer' => 0,
            'awaiting_provider_decision' => 0,
            'ended_without_success' => 0,
            'total' => 0,
          },
        }

        age_group_counts.map do |item|
          age_group = item['age_group']
          status = item['status']
          count = item['count']

          counts[age_group].merge!({ status => count })
        end

        counts
      end

      def age_group_counts
        @age_group_counts ||= ActiveRecord::Base
          .connection
          .execute(candidate_query_by_age_group)
          .to_a
      end
    end
  end
end
