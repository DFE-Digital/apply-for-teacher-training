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
                  END status,
                  CASE
                    WHEN f.equality_and_diversity->>'sex' IS NULL THEN 'Prefer not to say'
                    ELSE f.equality_and_diversity->>'sex'
                  END sex
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
              raw_data.status,
              raw_data.sex,
              COUNT(*)
          FROM
              raw_data
          GROUP BY
          raw_data.sex, raw_data.status
        SQL
      end
    end
  end
end
