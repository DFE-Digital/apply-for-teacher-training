module Publications
  module MonthlyStatistics
    class MonthlyStatisticsReport < ApplicationRecord
      MISSING_VALUE = 'n/a'.freeze

      def write_statistic(key, value)
        self.statistics = (statistics || {}).merge(key.to_s => value)
      end

      def read_statistic(key)
        statistics[key.to_s] || MISSING_VALUE
      end

      def load_table_data
        load_applications_by_status
        load_candidates_by_status
        load_by_age_group
        load_by_course_age_group
        load_by_area
        load_by_sex
        load_applications_by_course_type
        load_applications_by_primary_specialist_subject
        load_applications_by_secondary_subject
        load_applications_by_provider_area
      end

      def deferred_application_count
        @deferred_application_count ||=
          ApplicationForm.
            joins(:application_choices).
            where('application_choices.current_recruitment_cycle_year > application_forms.recruitment_cycle_year').
            distinct('application_forms.id').
            count
      end

    private

      def load_by_course_age_group
        write_statistic(
          :by_course_age_group,
          Publications::MonthlyStatistics::ByCourseAgeGroup.new.table_data,
        )
      end

      def load_by_area
        write_statistic(
          :by_area,
          Publications::MonthlyStatistics::ByArea.new.table_data,
        )
      end

      def load_by_sex
        write_statistic(
          :by_sex,
          Publications::MonthlyStatistics::BySex.new.table_data,
        )
      end

      def load_applications_by_status
        write_statistic(
          :applications_by_status,
          Publications::MonthlyStatistics::ByStatus.new.table_data,
        )
      end

      def load_candidates_by_status
        write_statistic(
          :candidates_by_status,
          Publications::MonthlyStatistics::ByStatus.new(by_candidate: true).table_data,
        )
      end

      def load_by_age_group
        write_statistic(
          :by_age_group,
          Publications::MonthlyStatistics::ByAgeGroup.new.table_data,
        )
      end

      def load_applications_by_course_type
        write_statistic(
          :by_course_type,
          Publications::MonthlyStatistics::ByCourseType.new.table_data,
        )
      end

      def load_applications_by_primary_specialist_subject
        write_statistic(
          :by_primary_specialist_subject,
          Publications::MonthlyStatistics::ByPrimarySpecialistSubject.new.table_data,
        )
      end

      def load_applications_by_secondary_subject
        write_statistic(
          :by_secondary_subject,
          Publications::MonthlyStatistics::BySecondarySubject.new.table_data,
        )
      end

      def load_applications_by_provider_area
        write_statistic(
          :by_provider_area,
          Publications::MonthlyStatistics::ByProviderArea.new.table_data,
        )
      end
    end
  end
end
