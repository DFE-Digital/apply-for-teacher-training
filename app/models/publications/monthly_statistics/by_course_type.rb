module Publications
  module MonthlyStatistics
    class ByCourseType < Publications::MonthlyStatistics::Base
      def table_data
        {
          rows: rows,
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
            'Received an offer' => offer_count(statuses),
            'Awaiting provider decisions' => awaiting_decision_count(statuses),
            'Unsuccessful' => unsuccessful_count(statuses),
            'Total' => statuses_count(statuses),
          }
        end
      end

      def column_totals_for(rows)
        _program_type, *statuses = rows.first.keys

        statuses.map do |column_name|
          column_total = rows.inject(0) { |total, hash| total + hash[column_name] }
          column_total
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

        group_query_excluding_deferred_offers.map do |item|
          program_type, status = item[0]
          count = item[1]
          counts[program_type_lookup(program_type)]&.merge!({ status => count })
        end

        counts
      end

      def program_type_lookup(subject)
        {
          'HE' => 'Higher education',
          'TA' => 'Postgraduate teaching apprenticeship',
          'SC' => 'School-centred initial teacher training (SCITT)',
          'SD' => 'School Direct (fee-paying)',
          'SS' => 'School Direct (salaried)',
        }[subject]
      end

      def group_query_excluding_deferred_offers
        group_query(recruitment_cycle_year: RecruitmentCycle.current_year)
          .where.not(status: :offer_deferred)
          .group('courses.program_type', 'status')
          .count
      end

      def group_query(recruitment_cycle_year:)
        ApplicationChoice
          .joins(:course)
          .joins(application_form: :candidate)
          .where('candidates.hide_in_reporting IS NOT TRUE')
          .where(current_recruitment_cycle_year: recruitment_cycle_year)
      end
    end
  end
end
