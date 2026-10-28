module DfE
  module Bigquery
    class WithdrawalReasonsMetrics
      include ::DfE::Bigquery::Relation

      SELECT_COLUMNS = %w[
        provider_code
        provider_id
        provider_name
        recruitment_cycle_year
        withdrawal_tier
        tier_withdrawal_reason
        before_accepting
        after_accepting
      ].freeze

      attr_reader :provider_id, :recruitment_cycle_year

      def initialize(provider_id:, recruitment_cycle_year:)
        @provider_id = provider_id.to_s
        @recruitment_cycle_year = recruitment_cycle_year
      end

      def table_name
        'dataform.provider_withdrawal_reasons'
      end

      def data
        query(
          select(SELECT_COLUMNS.join(', '))
          .where(
            provider_id:,
            recruitment_cycle_year:,
          ).to_sql,
        )
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
          ATTRIBUTES.to_h do |curr|
            [curr.to_s, public_send(curr)]
          end
        end
      end
    end
  end
end
