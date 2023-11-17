module Publications
  module MonthlyStatistics
    module DescribeQueries
      delegate :candidate_headline_statistics_query,
               :age_group_query,
               :sex_query,
               :area_query,
               :phase_query,
               :route_into_teaching_query,
               :primary_subject_query,
               :secondary_subject_query,
               :provider_region_query,
               :provider_region_and_subject_query,
               :candidate_area_and_subject_query,
               to: ::DfE::Bigquery::ApplicationMetrics

      def describe
        {
          candidate_headline_statistics_query: candidate_headline_statistics_query(cycle_week:),
          age_group_query: age_group_query(cycle_week:),
          sex_query: sex_query(cycle_week:),
          area_query: area_query(cycle_week:),
          phase_query: phase_query(cycle_week:),
          route_into_teaching_query: route_into_teaching_query(cycle_week:),
          primary_subject_query: primary_subject_query(cycle_week:),
          secondary_subject_query: secondary_subject_query(cycle_week:),
          provider_region_query: provider_region_query(cycle_week:),
          provider_region_and_subject_query: provider_region_and_subject_query(cycle_week:),
          candidate_area_and_subject_query: candidate_area_and_subject_query(cycle_week:),
        }.each do |key, value|
          # rubocop:disable Rails/Output
          puts "========= #{key.to_s.humanize} =========="
          puts value
          puts '=' * 40
          # rubocop:enable Rails/Output
        end; nil
      end
    end
  end
end
