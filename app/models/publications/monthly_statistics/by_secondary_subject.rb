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
          subject_names_and_codes = choice.current_course.subjects.map { |s| [s.name, s.code] }.to_h
          dominant_subject = MinisterialReport.determine_dominant_course_subject_for_report(choice.current_course.name,
                                                                                            choice.current_course.level,
                                                                                            subject_names_and_codes)

          dominant_subject = dominant_subject.to_s.humanize
          dominant_subject = 'Subject not recognised' if dominant_subject == 'Secondary'

          if subject_counts[dominant_subject].present?
            if subject_counts[dominant_subject][status].present?
              subject_counts[dominant_subject][status] += 1
            else
              subject_counts[dominant_subject][status] = 1
            end
          else
            subject_counts[dominant_subject] = { status => 1 }
          end

          subject_counts
        end.sort.to_h
      end

      def application_choices_with_subjects
        ApplicationChoice
          .joins(application_form: :candidate)
          .joins(:current_course)
          .preload(current_course: :subjects)
          .where('candidates.hide_in_reporting IS NOT TRUE')
          .where(current_recruitment_cycle_year: RecruitmentCycle.current_year)
          .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
          .where('courses.level' => 'secondary')
      end
    end
  end
end
