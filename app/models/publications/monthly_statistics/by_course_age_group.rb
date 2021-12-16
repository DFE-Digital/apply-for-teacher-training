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

      def formatted_group_query
        counts = {
          'Primary' => {},
          'Secondary' => {},
          'Further education' => {},
        }

        applications_to_course_levels_counts.map do |item|
          level, status = item[0]
          count = item[1]
          counts[level].merge!({ status => count })
        end

        counts
      end

      def applications_to_course_levels_counts
        application_choices
          .group('courses.level', 'status')
          .count
      end
    end
  end
end
