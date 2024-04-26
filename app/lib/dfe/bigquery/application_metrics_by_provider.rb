module DfE
  module Bigquery
    class ApplicationMetricsByProvider
      include ::DfE::Bigquery::Relation
      attr_reader :cycle_week,
                  :recruitment_cycle_year,
                  :nonprovider_filter,
                  :provider_filter,
                  :provider_filter_category

      def initialize(cycle_week:, provider_id: nil, recruitment_cycle_year: RecruitmentCycle.current_year)
        @provider_id = provider_id&.to_s
        @cycle_week = cycle_week
        @recruitment_cycle_year = recruitment_cycle_year
      end

      def table_name
        :'dataform.application_metrics_by_provider'
      end

      ### Candidates queries

      def candidate_submitted_to_date
        query(candidate_submitted_to_date_query)
      end

      def candidate_submitted_to_date_query
        select('nonprovider_filter, nonprovider_filter_category, cycle_week, recruitment_cycle_year, provider.id, number_of_candidates_submitted_to_date, number_of_candidates_submitted_to_same_date_previous_cycle, number_of_candidates_submitted_to_date_as_proportion_of_last_cycle')
        .where(
          'provider.id': @provider_id,
          cycle_week:,
          recruitment_cycle_year:,
        ).where(
          '(nonprovider_filter_category IN ("Secondary subject", "Primary subject") OR nonprovider_filter IN ("Primary", "Secondary"))',
        )
        .to_sql
      end

      ### Candidate All query

      def candidate_all_query
        select(select_columns.join(', '))
        .where(
          'provider.id': @provider_id,
          cycle_week:,
          recruitment_cycle_year:,
        ).where(<<~SQL.chomp).to_sql
          (
            nonprovider_filter_category = "Secondary subject"
            OR (nonprovider_filter_category = "Level" AND nonprovider_filter IN ("Primary", "Secondary"))
            OR nonprovider_filter = "All"
          )
        SQL
      end

      def candidate_all
        query(candidate_all_query)
      end

      ### National queries

      def national_all
        query(national_all_query)
      end

      def national_all_query
        select(select_columns.join(', '))
        .where(
          cycle_week:,
          recruitment_cycle_year:,
          teach_first_or_iot_filter: 'All',
          provider_filter_category: 'All',
        ).where(<<~SQL.chomp).to_sql
          (
            nonprovider_filter_category = "Secondary subject"
            OR (nonprovider_filter_category = "Level" AND nonprovider_filter IN ("Primary", "Secondary"))
            OR (nonprovider_filter = "All")
          )
        SQL
      end

    private

      def select_columns
        %w[nonprovider_filter
           nonprovider_filter_category
           cycle_week
           recruitment_cycle_year
           provider.id

           number_of_candidates_submitted_to_date
           number_of_candidates_submitted_to_same_date_previous_cycle
           number_of_candidates_submitted_to_date_as_proportion_of_last_cycle

           number_of_candidates_with_offers_to_date
           number_of_candidates_with_offers_to_same_date_previous_cycle
           number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle

           number_of_candidates_accepted_to_date
           number_of_candidates_accepted_to_same_date_previous_cycle
           number_of_candidates_accepted_to_date_as_proportion_of_last_cycle

           number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date
           number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle
           number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle

           number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date
           number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle
           number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle

           number_of_candidates_who_had_an_inactive_application_this_cycle_to_date
           number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates]
      end

      def result_class = self.class::Result

      class Result
        attr_reader :nonprovider_filter,
                    :nonprovider_filter_category,
                    :cycle_week,
                    :provider_id,
                    :recruitment_cycle_year,
                    :number_of_candidates_submitted_to_date,
                    :number_of_candidates_submitted_to_same_date_previous_cycle,
                    :number_of_candidates_submitted_to_date_as_proportion_of_last_cycle,
                    :number_of_candidates_with_offers_to_date,
                    :number_of_candidates_with_offers_to_same_date_previous_cycle,
                    :number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle,
                    :number_of_candidates_accepted_to_date,
                    :number_of_candidates_accepted_to_same_date_previous_cycle,
                    :number_of_candidates_accepted_to_date_as_proportion_of_last_cycle,
                    :number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date,
                    :number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle,
                    :number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date,
                    :number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle,
                    :number_of_candidates_who_had_an_inactive_application_this_cycle_to_date,
                    :number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates

        def initialize(attributes)
          attributes.each do |key, value|
            if respond_to?(key)
              instance_variable_set("@#{key}", value)
            end
          end
        end
      end
    end
  end
end
