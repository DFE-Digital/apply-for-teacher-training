module DfE
  module Bigquery
    class RegionalEdiMetrics
      include ::DfE::Bigquery::Relation

      SELECT_COLUMNS = %w[
        nonregion_filter
        nonregion_filter_category
        cycle_week
        recruitment_cycle_year
        region_filter
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
        number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle
        recruited_rate_to_date
        recruited_rate_to_same_date_previous_cycle
      ].freeze

      attr_reader :cycle_week,
                  :category,
                  :region,
                  :recruitment_cycle_year

      def initialize(cycle_week:, region:, category:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
        @cycle_week = cycle_week
        @region = region
        @category = category
        @recruitment_cycle_year = recruitment_cycle_year
      end

      def table_name
        '1_key_tables.application_metrics_by_region'
      end

      def data
        query(data_query)
      end

      def data_query
        select(SELECT_COLUMNS.join(', '))
        .where(
          region_filter: region,
          nonregion_filter_category: category.downcase == 'disability' ? 'HESA disability' : category,
          region_filter_category: 'ITL1',
          cycle_week:,
          recruitment_cycle_year:,
        ).to_sql
      end

    private

      def result_class = self.class::Result

      class Result
        ATTRIBUTES = SELECT_COLUMNS.map { |column| column.to_s.tr('.', '_') }
        attr_reader(*ATTRIBUTES)

        def initialize(attributes)
          attributes.each do |key, value|
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
