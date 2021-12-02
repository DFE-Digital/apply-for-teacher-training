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
          .execute(candidate_query)
          .to_a
      end

      def candidate_query
        <<~SQL
          WITH raw_data AS (
              SELECT
                  c.id,
                  f.id,
                  CASE
                    WHEN f.country IS NULL AND f.region_code IS NULL THEN 'no_region'
                    WHEN f.region_code IS NOT NULL THEN f.region_code
                    WHEN f.country IN (#{EU_EEA_SWISS_COUNTRY_CODES.map { |c| "'#{c}'" }.join(',')}) THEN 'european_economic_area'
                    ELSE 'rest_of_the_world'
                  END region_code,
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
                    AND ch.status IN (#{ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map { |status| "'#{status}'" }.join(',')})
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
              raw_data.region_code,
              raw_data.status,
              COUNT(*)
          FROM
              raw_data
          GROUP BY
          raw_data.region_code, raw_data.status
        SQL
      end
    end
  end
end
