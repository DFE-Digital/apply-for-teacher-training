module Publications
  module MonthlyStatistics
    class ByArea < Publications::MonthlyStatistics::Base
      NON_UK_REGIONS = %w[european_economic_area rest_of_the_world].freeze

      def table_data
        {
          rows: apply_minimum_value_rule_to_rows(rows),
          column_totals: apply_minimum_value_rule_to_totals(column_totals_for(rows)),
        }
      end

    private

      def rows
        @rows ||= query_rows
      end

      def query_rows
        @rows ||= formatted_group_query.map do |region_code, statuses|
          {
            'Area' => column_label_for(region_code),
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

      def column_label_for(region_code)
        I18n.t("application_form.region_codes.#{region_code}", default: region_code.humanize)
      end

      def available_region_codes
        @available_region_codes ||=
          ApplicationForm.region_codes.keys.reject { |region_code| NON_UK_REGIONS.include?(region_code) } +
          ApplicationForm.region_codes.keys.select { |region_code| NON_UK_REGIONS.include?(region_code) }
      end

      def formatted_group_query
        counts = available_region_codes.index_with { |_region_code| {} }

        group_query_excluding_deferred_offers.map do |item|
          increment_area_status_count(counts, item)
        end

        counts
      end

      def increment_area_status_count(counts, item)
        area = item['region_code']
        status = item['status']
        count = item['count']

        running_count = counts[area]&.fetch(status, 0)
        counts[area]&.merge!({ status => running_count + count })
      end

      def group_query_excluding_deferred_offers
        ActiveRecord::Base
          .connection
          .execute(candidate_query_by_area)
          .to_a
      end
    end
  end
end
