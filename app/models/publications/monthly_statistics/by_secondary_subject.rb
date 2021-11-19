module Publications
  module MonthlyStatistics
    class BySecondarySubject < Publications::MonthlyStatistics::Base
      SECONDARY_SUBJECTS = [
        'Art and design',
        'Science',
        'Biology',
        'Business studies',
        'Chemistry',
        'Citizenship',
        'Classics',
        'Communication and media studies',
        'Computing',
        'Dance',
        'Design and technology',
        'Drama',
        'Economics',
        'English',
        'Geography',
        'Health and social care',
        'History',
        'Mathematics',
        'Modern foreign languages',
        'Music',
        'Philosophy',
        'Physical education',
        'Physics',
        'Psychology',
        'Religious education',
        'Social sciences',
        'Further education',
      ].freeze

      MODERN_FOREIGN_LANGUAGES = [
        'French',
        'English as a second or other language',
        'German',
        'Italian',
        'Japanese',
        'Mandarin',
        'Russian',
        'Spanish',
        'Modern Languages',
        'Modern languages (other)',
      ].freeze

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
        counts = SECONDARY_SUBJECTS.index_with { |_subject| {} }
        languages_counter = []

        group_query_excluding_deferred_offers.map do |item|
          subject, status = item[0]
          count = item[1]

          if MODERN_FOREIGN_LANGUAGES.include?(subject)
            languages_counter << { status => count }
          else
            counts[subject].merge!({ status => count })
          end
        end

        group_query_including_deferred_offers.map do |item|
          subject, status = item[0]
          count = item[1]

          if MODERN_FOREIGN_LANGUAGES.include?(subject)
            languages_counter << { status => count }
          else
            counts[subject]&.merge!({ status => count })
          end
        end

        counts['Modern foreign languages']&.merge!(modern_foreign_languages_sum(languages_counter))

        counts
      end

      def modern_foreign_languages_sum(languages_counter)
        languages_counter.each_with_object(Hash.new(0)) do |hash, sum|
          hash.each { |key, value| sum[key] += value }
        end
      end

      def group_query_excluding_deferred_offers
        group_query(recruitment_cycle_year: RecruitmentCycle.current_year)
          .where.not(status: 'offer_deferred')
          .where(course: { level: 'secondary' })
          .group('subjects.name', 'status')
          .count
      end

      def group_query_including_deferred_offers
        group_query(recruitment_cycle_year: RecruitmentCycle.previous_year)
          .where(status: 'offer_deferred')
          .where(course: { level: 'secondary' })
          .group('subjects.name', 'status_before_deferral')
          .count
      end

      def group_query(recruitment_cycle_year:)
        ApplicationChoice
          .joins(course: :subjects)
          .where(current_recruitment_cycle_year: recruitment_cycle_year)
      end
    end
  end
end
