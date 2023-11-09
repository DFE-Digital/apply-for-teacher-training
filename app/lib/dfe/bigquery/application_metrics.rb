module DfE
  module Bigquery
    class ApplicationMetrics
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
                    :subject_filter

      def initialize(attributes)
        attributes.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def self.table_name
        :'dataform.application_metrics'
      end

      def self.where(conditions)
        ::DfE::Bigquery::Table.new(name: table_name).where(conditions)
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

      def self.candidate_headline_statistics_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Total',
        ).to_sql
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
        .to_sql
      end

      def self.sex_query(cycle_week:)
        where(
          recruitment_cycle_year:,
          cycle_week:,
          subject_filter_category: 'Total excluding Further Education',
          nonsubject_filter_category: 'Sex',
        )
        .to_sql
      end

      def self.recruitment_cycle_year
        RecruitmentCycle.current_year
      end

      def self.query(sql_query)
        ::DfE::Bigquery.client.query(sql_query).map { |result| new(result) }
      end
    end
  end
end
