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
            'Received an offer' => offer_count(statuses),
            'Awaiting provider decisions' => awaiting_decision_count(statuses),
            'Unsuccessful' => unsuccessful_count(statuses),
            'Total' => statuses_count(statuses),
          }
        end
      end

      def column_totals_for(rows)
        _area, *statuses = rows.first.keys

        statuses.map do |column_name|
          rows.inject(0) { |total, hash| total + hash[column_name] }
        end
      end

      MINIMUM_VISIBLE_VALUE = 5
      def apply_minimum_value_rule(count)
        count.is_a?(Numeric) && count < MINIMUM_VISIBLE_VALUE ? '0 to 4' : count
      end

      def apply_minimum_value_rule_to_rows(rows)
        rows.map do |hash|
          hash.transform_values { |count| apply_minimum_value_rule(count) }
        end
      end

      def apply_minimum_value_rule_to_totals(totals)
        totals.map { |count| apply_minimum_value_rule(count) }
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

        group_query_excluding_deferred_offers.reject { |item| item['status'] == 'offer_deferred' }.map do |item|
          increment_area_status_count(counts, item, 'status')
        end
        group_query_for_deferred_offers.map do |item|
          increment_area_status_count(counts, item, 'status_before_deferral')
        end

        counts
      end

      def increment_area_status_count(counts, item, status_attribute)
        area = item['region_code'] || 'no_region'
        status = item[status_attribute]
        count = item['count']
        running_count = counts[area]&.fetch(status, 0)
        counts[area]&.merge!({ status => running_count + count })
      end

      def group_query_for_deferred_offers
        group_query(
          cycle: RecruitmentCycle.previous_year,
          group_by_attribute: :region_code,
          status_attribute: 'status_before_deferral',
        )
      end

      def group_query_excluding_deferred_offers
        group_query(
          cycle: RecruitmentCycle.current_year,
          group_by_attribute: :region_code,
        )
      end

      def group_query(cycle:, group_by_attribute:, status_attribute: :status)
        without_subsequent_applications_query =
          "AND (
            NOT EXISTS (
              SELECT 1
              FROM application_forms
              AS subsequent_application_forms
              WHERE application_forms.id = subsequent_application_forms.previous_application_form_id
            )
          )"
        with_statuses =
          if status_attribute.to_s == 'status_before_deferral'
            "AND application_choices.status = 'offer_deferred'"
          else
            ''
          end

        query = "SELECT
                   COUNT(application_choices_with_minimum_statuses.id),
                   application_choices_with_minimum_statuses.#{status_attribute},
                   #{group_by_attribute}
                  FROM (
                    SELECT application_choices.id as id,
                           application_choices.status_before_deferral as status_before_deferral,
                           application_choices.status as status,
                           application_forms.region_code as region_code,
                           ROW_NUMBER() OVER (
                            PARTITION BY application_forms.id
                            ORDER BY
                            CASE application_choices.#{status_attribute}
                            WHEN 'offer_deferred' THEN 0
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
                          #{without_subsequent_applications_query}
                          #{with_statuses}
                          ) AS application_choices_with_minimum_statuses
                  WHERE application_choices_with_minimum_statuses.row_number = 1
                  GROUP BY #{[group_by_attribute, status_attribute].compact.join(',')}"

        ActiveRecord::Base
          .connection
          .execute(query)
          .to_a
      end
    end
  end
end
