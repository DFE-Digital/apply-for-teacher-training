module MonthlyStatistics
  class BySex < MonthlyStatistics::Base
    def table_data
      {
        rows: apply_minimum_value_rule_to_rows(rows),
        column_totals: apply_minimum_value_rule_to_totals(column_totals_for(rows)),
      }
    end

  private

    def rows
      @rows ||= formatted_group_query.map do |sex, statuses|
        {
          'Sex' => column_label_for(sex),
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
      _sex, *statuses = rows.first.keys

      statuses.map do |column_name|
        column_total = rows.inject(0) { |total, hash| total + hash[column_name] }
        column_total
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
        sex, status = item[0]
        count = item[1]
        counts[sex]&.merge!({ status => count })
      end

      group_query_for_deferred_offers.map do |item|
        sex, status = item[0]
        count = item[1]
        counts[sex]&.merge!({ status => count })
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
        .group("application_forms.equality_and_diversity->'sex'", 'status')
    end
  end
end
