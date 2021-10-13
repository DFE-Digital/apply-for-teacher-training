module MonthlyStatistics
  class BySex
    def table_data
      {
        rows: rows,
        column_totals: column_totals_for(rows),
      }
    end

  private

    def rows
      @rows ||= formatted_group_query.map do |sex, statuses|
        {
          'Sex' => sex,
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

    def formatted_group_query
      counts = {
        'female' => {},
        'male' => {},
        'intersex' => {},
        I18n.t('equality_and_diversity.sex.opt_out.label') => {},
      }

      group_query.map do |item|
        sex, status = item[0]
        count = item[1]
        puts sex
        counts[sex].merge!({ status => count })
      end

      counts
    end

    def group_query
      ApplicationChoice
        .joins(:application_form)
        .where(current_recruitment_cycle_year: RecruitmentCycle.current_year)
        .group("application_forms.equality_and_diversity->'sex'", 'status')
        .count
    end

    def recruited_count(statuses)
      statuses['recruited'] || 0
    end

    def pending_count(statuses)
      statuses['pending_conditions'] || 0
    end

    def offer_count(statuses)
      statuses['offer'] || 0
    end

    def awaiting_decision_count(statuses)
      (statuses['awaiting_provider_decision'] || 0) + (statuses['interviewing'] || 0)
    end

    def unsuccessful_count(statuses)
      (statuses['declined'] || 0) + (statuses['rejected'] || 0) + (statuses['conditions_not_met'] || 0)
    end

    def statuses_count(statuses)
      recruited_count(statuses) +
        pending_count(statuses) +
        offer_count(statuses) +
        awaiting_decision_count(statuses) +
        unsuccessful_count(statuses)
    end
  end
end
