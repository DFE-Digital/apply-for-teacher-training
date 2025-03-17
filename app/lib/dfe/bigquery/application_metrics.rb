module DfE
  module Bigquery
    class ApplicationMetrics
      include ::DfE::Bigquery::Relation

      def initialize(cycle_week:)
        @cycle_week = cycle_week
        @recruitment_cycle_year = RecruitmentCycleTimetable.current_year
      end

      def table_name
        '1_key_tables.application_metrics'
      end

      def candidate_headline_statistics
        query(candidate_headline_statistics_query).first
      end

      def age_group
        query(age_group_query)
      end

      def sex
        query(sex_query)
      end

      def area
        query(area_query)
      end

      def phase
        query(phase_query)
      end

      def route_into_teaching
        query(route_into_teaching_query)
      end

      def primary_subject
        query(primary_subject_query)
      end

      def secondary_subject
        query(secondary_subject_query)
      end

      def provider_region
        query(provider_region_query)
      end

      def provider_region_and_subject
        query(provider_region_and_subject_query)
      end

      def candidate_area_and_subject
        query(candidate_area_and_subject_query)
      end

      def candidate_headline_statistics_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Total',
        )
        .to_sql
      end

      def age_group_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Age group',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def phase_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Level',
          nonsubject_filter_category: 'Total',
        )
        .where('subject_filter != "Further Education"')
        .order(subject_filter: :asc)
        .to_sql
      end

      def area_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Candidate region',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def sex_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Sex',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def route_into_teaching_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Route into teaching',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def primary_subject_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Primary subject',
          nonsubject_filter_category: 'Total',
        )
        .order(subject_filter: :asc)
        .to_sql
      end

      def secondary_subject_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Secondary subject excluding Further Education',
          nonsubject_filter_category: 'Total',
        )
        .order(subject_filter: :asc)
        .to_sql
      end

      def provider_region_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Provider region',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def provider_region_and_subject_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          nonsubject_filter_category: 'Provider region',
        )
        .where('subject_filter_category IN ("Primary subject", "Secondary subject excluding Further Education")')
        .to_sql
      end

      def candidate_area_and_subject_query
        where(
          recruitment_cycle_year:,
          cycle_week:,
          nonsubject_filter_category: 'Candidate region',
        )
        .where('subject_filter_category IN ("Primary subject", "Secondary subject excluding Further Education")')
        .to_sql
      end

    private

      attr_reader :cycle_week, :recruitment_cycle_year
      def result_class = self.class::Result

      class Result
        attr_reader :number_of_candidates_submitted_to_date,
                    :number_of_candidates_submitted_to_same_date_previous_cycle,
                    :number_of_candidates_with_offers_to_date,
                    :number_of_candidates_with_offers_to_same_date_previous_cycle,
                    :number_of_candidates_accepted_to_date,
                    :number_of_candidates_accepted_to_same_date_previous_cycle,
                    :number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date,
                    :number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date,
                    :number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_with_deferred_offers_from_this_cycle_to_date,
                    :number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date,
                    :number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date,
                    :number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle,
                    :first_date_in_week,
                    :last_date_in_week,
                    :cycle_week,
                    :nonsubject_filter,
                    :subject_filter,
                    :recruitment_cycle_year,
                    :subject_filter_category

        def initialize(attributes)
          attributes.each do |key, value|
            instance_variable_set("@#{key}", value) if respond_to?(key)
          end
        end
      end
    end
  end
end
