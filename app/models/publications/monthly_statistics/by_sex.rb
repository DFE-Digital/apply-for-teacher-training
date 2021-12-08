module Publications
  module MonthlyStatistics
    class BySex < Publications::MonthlyStatistics::Base
      def table_data
        {
          rows: apply_minimum_value_rule_to_rows(rows),
          column_totals: apply_minimum_value_rule_to_totals(column_totals_for(rows)),
        }
      end

      def rows
        @rows ||= formatted_group_query.map do |sex, statuses|
          {
            'Sex' => column_label_for(sex),
            'Recruited' => recruited_count(statuses),
            'Conditions pending' => pending_count(statuses),
            'Deferred' => deferred_count(statuses),
            'Received an offer' => offer_count(statuses),
            'Awaiting provider decisions' => awaiting_decision_count(statuses),
            'Unsuccessful' => unsuccessful_count(statuses),
            'Total' => statuses_count(statuses),
          }
        end
      end

      def column_label_for(sex)
        I18n.t("equality_and_diversity.sex.#{sex}.label", default: sex)
      end

      def formatted_group_query
        counts = {
          'female' => {},
          'male' => {},
          'intersex' => {},
          I18n.t('equality_and_diversity.sex.opt_out.label') => {},
        }

        group_query_excluding_deferred_offers.map do |item|
          counts[item['sex']]&.merge!({ item['status'] => item['count'] })
        end

        counts
      end

      def group_query_excluding_deferred_offers
        ActiveRecord::Base
          .connection
          .execute(candidate_query_by_sex)
          .to_a
      end
    end
  end
end
