module MonthlyStatistics
  class ByArea < MonthlyStatistics::Base
    def table_data
      {
        rows: rows,
        column_totals: column_totals_for(rows),
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
        column_total = rows.inject(0) { |total, hash| total + hash[column_name] }
        column_total
      end
    end

    def column_label_for(region_code)
      I18n.t("application_form.region_codes.#{region_code}", default: region_code.humanize)
    end

    def formatted_group_query
      counts = ApplicationForm.region_codes.values.index_with { |_region_code| {} }

      group_query_excluding_deferred_offers.map do |item|
        area = item['region_code']
        status = item['status']
        count = item['count']
        counts[area]&.merge!({ status => count })
      end
      group_query_for_deferred_offers.map do |item|
        area = item['region_code']
        status = item['status_before_deferral']
        count = item['count']
        running_count = counts[area]&.fetch(status, 0)
        counts[area]&.merge!({ status => running_count + count })
      end

      counts
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
          "AND NOT application_choices.status = 'offer_deferred'"
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
