module Publications
  module MonthlyStatistics
    class ByPrimarySpecialistSubject < Publications::MonthlyStatistics::Base
      def table_data
        {
          rows: rows,
          column_totals: column_totals_for(rows),
        }
      end

    private

      def rows
        @rows ||= formatted_group_query.map do |subject, statuses|
          {
            'Subject' => subject,
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
        _subject, *statuses = rows.first.keys

        statuses.map do |column_name|
          column_total = rows.inject(0) { |total, hash| total + hash[column_name] }
          column_total
        end
      end

      def formatted_group_query
        application_choices_with_subjects.reduce({}) do |subject_counts, choice|
          status = choice.status
          primary_subject = choice.current_course.subjects.find { |subject| subject.name.downcase.include? 'primary' }&.name

          if primary_subject
            if subject_counts[primary_subject].present?
              if subject_counts[primary_subject][status].present?
                subject_counts[primary_subject][status] += 1
              else
                subject_counts[primary_subject][status] = 1
              end
            else
              subject_counts[primary_subject] = { status => 1 }
            end
          end

          subject_counts
        end
      end

      def application_choices_with_subjects
        application_choices
          .preload(current_course: :subjects)
          .where('courses.level' => 'primary')
      end
    end
  end
end
