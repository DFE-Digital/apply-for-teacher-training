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
        area, status = item[0]
        count = item[1]
        counts[area]&.merge!({ status => count })
      end

      group_query_for_deferred_offers.map do |item|
        area, status = item[0]
        count = item[1]
        counts[area]&.merge!({ status => count })
      end

      counts
    end

    def group_query_for_deferred_offers
      group_query(recruitment_cycle_year: RecruitmentCycle.previous_year)
        .where(status: :offer_deferred)
        .count
    end

    def group_query_excluding_deferred_offers
      group_query(recruitment_cycle_year: RecruitmentCycle.current_year)
        .where.not(status: :offer_deferred)
        .count
    end

    def group_query(recruitment_cycle_year: RecruitmentCycle.current_year)
      ApplicationChoice
        .joins(:application_form)
        .where(application_forms: { recruitment_cycle_year: recruitment_cycle_year })
        .where.not(
          application_forms: ApplicationForm.select(:previous_application_form_id).where.not(previous_application_form_id: nil),
        )
        .group('application_forms.region_code', 'status')
    end
  end
end
