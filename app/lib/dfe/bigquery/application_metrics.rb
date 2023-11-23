module DfE
  module Bigquery
    class ApplicationMetrics
      extend ::DfE::Bigquery::Relation
      attr_accessor :number_of_candidates_submitted_to_date,
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
                    :subject_filter_category

      def initialize(attributes)
        attributes.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def self.table_name
        :'dataform.application_metrics'
      end

      def self.candidate_headline_statistics(cycle_week:)
        query(candidate_headline_statistics_query(cycle_week:)).first
      end

      def self.age_group(cycle_week:)
        query(age_group_query(cycle_week:))
      end

      def self.sex(cycle_week:)
        query(sex_query(cycle_week:))
      end

      def self.area(cycle_week:)
        query(area_query(cycle_week:))
      end

      def self.phase(cycle_week:)
        query(phase_query(cycle_week:))
      end

      def self.route_into_teaching(cycle_week:)
        query(route_into_teaching_query(cycle_week:))
      end

      def self.primary_subject(cycle_week:)
        query(primary_subject_query(cycle_week:))
      end

      def self.secondary_subject(cycle_week:)
        query(secondary_subject_query(cycle_week:))
      end

      def self.provider_region(cycle_week:)
        query(provider_region_query(cycle_week:))
      end

      def self.provider_region_and_subject(cycle_week:)
        query(provider_region_and_subject_query(cycle_week:))
      end

      def self.candidate_area_and_subject(cycle_week:)
        query(candidate_area_and_subject_query(cycle_week:))
      end

      def self.candidate_headline_statistics_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Total',
        )
        .to_sql
      end

      def self.age_group_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Age group',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def self.phase_query(cycle_week:)
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

      def self.area_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Candidate region',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def self.sex_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Sex',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def self.route_into_teaching_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Route into teaching',
        )
        .to_sql
      end

      def self.primary_subject_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Primary subject',
          nonsubject_filter_category: 'Total',
        )
        .to_sql
      end

      def self.secondary_subject_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Secondary subject excluding Further Education',
          nonsubject_filter_category: 'Total',
        )
        .order(subject_filter: :asc)
        .to_sql
      end

      def self.provider_region_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Provider region',
        )
        .order(nonsubject_filter: :asc)
        .to_sql
      end

      def self.provider_region_and_subject_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          nonsubject_filter_category: 'Provider region',
        )
        .where('subject_filter_category IN ("Primary subject", "Secondary subject excluding Further Education")')
        .to_sql
      end

      def self.candidate_area_and_subject_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          nonsubject_filter_category: 'Candidate region',
        )
        .where('subject_filter_category IN ("Primary subject", "Secondary subject excluding Further Education")')
        .to_sql
      end

      def self.recruitment_cycle_year
        RecruitmentCycle.current_year
      end
    end
  end
end
