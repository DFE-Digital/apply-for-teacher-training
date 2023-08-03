module Publications
  module MonthlyStatistics
    class ByCourseType < Publications::MonthlyStatistics::Base
      def table_data
        {
          rows:,
          column_totals: column_totals_for(rows),
        }
      end

    private

      def rows
        @rows ||= formatted_group_query.map do |program_type, statuses|
          {
            'Course type' => program_type,
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
          'Higher education' => {},
          'Postgraduate teaching apprenticeship' => {},
          'School-centred initial teacher training (SCITT)' => {},
          'School Direct (fee-paying)' => {},
          'School Direct (salaried)' => {},
        }

        applications_to_program_counts.map do |item|
          program_type, status = item[0]
          count = item[1]
          counts[program_type_lookup(program_type)]&.merge!({ status => count })
        end

        counts
      end

      def program_type_lookup(subject)
        {
          'higher_education_programme' => 'Higher education',
          'higher_education_salaried_programme' => 'Higher education (salaried)',
          'pg_teaching_apprenticeship' => 'Postgraduate teaching apprenticeship',
          'scitt_programme' => 'School-centred initial teacher training (SCITT)',
          'scitt_salaried_programme' => 'School-cented initial teacher training (SCITT) (salaried)',
          'school_direct_training_programme' => 'School Direct (fee-paying)',
          'school_direct_salaried_training_programme' => 'School Direct (salaried)',
        }[subject]
      end

      def applications_to_program_counts
        application_choices
          .group('courses.program_type', 'status')
          .count
      end
    end
  end
end
