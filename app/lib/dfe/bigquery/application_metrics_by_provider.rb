module DfE
  module Bigquery
    class ApplicationMetricsByProvider
      include ::DfE::Bigquery::Relation

      SELECT_COLUMNS = %w[nonprovider_filter
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

                          offer_rate_to_date
                          offer_rate_to_same_date_previous_cycle

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
                          number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates
                          number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle].freeze

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
        '1_key_tables.application_metrics_by_provider'
      end

      ### Candidate All query

      def provider_data
        query(provider_data_query)
      end

      def provider_data_query
        select(SELECT_COLUMNS.join(', '))
        .where(
          'provider.id': @provider_id,
          teach_first_or_iot_filter: 'All',
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

      ### National queries

      def national_data
        query(national_data_query)
      end

      def national_data_query
        select(SELECT_COLUMNS.join(', '))
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

      def result_class = self.class::Result

      class Result
        ATTRIBUTES = SELECT_COLUMNS.map { |column| column.to_s.tr('.', '_') }
        attr_reader(*ATTRIBUTES)

        def initialize(attributes)
          attributes.each do |key, value|
            key = 'provider_id' if key == :id

            if respond_to?(key)
              instance_variable_set("@#{key}", value)
            end
          end
        end

        def attributes
          ATTRIBUTES.each_with_object({}) do |curr, obj|
            obj[curr.to_s] = public_send(curr)
          end
        end
      end
    end
  end
end
