module MonthlyStatistics
  class BySecondarySubject < MonthlyStatistics::Base
    SUBJECTS = [
      'Art and design',
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
      'History',
      'Mathematics',
      'French',
      'German',
      'Mandarin',
      'Spanish',
      'Modern languages (other)',
      'Music',
      'Physical education',
      'Physics',
      'Psychology',
      'Religious education',
      'Social sciences',
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
      counts = SUBJECTS.index_with { |_subject| {} }

      group_query_excluding_deferred_offers.map do |item|
        subject, status = item[0]
        count = item[1]

        counts[subject].merge!({ status => count })
      end

      group_query_including_deferred_offers.map do |item|
        subject, status_before_deferral = item[0]
        count = item[1]

        counts[subject].merge!({ status_before_deferral => count })
      end

      counts
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
