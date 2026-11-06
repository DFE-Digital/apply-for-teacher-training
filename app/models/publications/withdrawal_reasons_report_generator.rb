module Publications
  class WithdrawalReasonsReportGenerator
    attr_reader :client, :provider_id, :recruitment_cycle_year

    def initialize(provider_id:, recruitment_cycle_year:)
      @provider_id = provider_id
      @recruitment_cycle_year = recruitment_cycle_year
      @client = DfE::Bigquery::WithdrawalReasonsMetrics.new(
        provider_id:,
        recruitment_cycle_year:,
      )
    end

    def call
      if data.present?
        ActiveRecord::Base.transaction do
          current = Publications::WithdrawalReasonsReport.create!(
            provider_id:,
            recruitment_cycle_year:,
            statistics: data,
          )

          Publications::WithdrawalReasonsReport.where(
            provider_id:,
            recruitment_cycle_year:,
          ).where.not(
            id: current.id,
          ).destroy_all
        end
      end
    end

    def data
      client.data.map(&:attributes)
    end
  end
end
