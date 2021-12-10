module Publications
  module MonthlyStatistics
    class ByCourseAgeGroup < Publications::MonthlyStatistics::Base
      def table_data
        {
          rows: rows,
          column_totals: column_totals_for(rows),
        }
      end

    private

      def rows
        @rows ||= formatted_group_query.map do |age_group, statuses|
          {
            'Course phase' => age_group,
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

      def column_totals_for(rows)
        _age_group, *statuses = rows.first.keys

        statuses.map do |column_name|
          column_total = rows.inject(0) { |total, hash| total + hash[column_name] }
          column_total
        end
      end

      def formatted_group_query
        counts = {
          'Primary' => {},
          'Secondary' => {},
          'Further education' => {},
        }

        group_query_excluding_deferred_offers.map do |item|
          level, status = item[0]
          count = item[1]
          counts[level].merge!({ status => count })
        end

        counts
      end

      def group_query_excluding_deferred_offers
        group_query(recruitment_cycle_year: RecruitmentCycle.current_year)
          .where.not(status: 'offer_deferred')
          .group('courses.level', 'status')
          .count
      end

      def group_query(recruitment_cycle_year:)
        ApplicationChoice
          .joins(:course)
          .joins(application_form: :candidate)
          .where('candidates.hide_in_reporting IS NOT true')
          .where(current_recruitment_cycle_year: recruitment_cycle_year)
      end
    end
  end
end
