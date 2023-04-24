module ProviderInterface
  class CandidateWithdrawalDataByProvider
    CONFIG_PATH = 'config/withdrawal_reasons.yml'.freeze

    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end

    def submitted_withdrawal_reason_count
      ApplicationChoice
        .where('provider_ids @> ARRAY[?]::bigint[]', provider)
        .where.not(structured_withdrawal_reasons: [])
        .where(current_recruitment_cycle_year: RecruitmentCycle.current_year)
        .count
    end

    def withdrawal_data
      selectable_reasons.map do |reason|
        {
          header: reason[:label],
          values: [
            withdrawal_query[reason[:id]] || 0,
          ]
        }
      end
    end

  private

    def withdrawal_query
      ApplicationChoice
        .where('provider_ids @> ARRAY[?]::bigint[]', provider)
        .where(current_recruitment_cycle_year: RecruitmentCycle.current_year)
        .pluck(Arel.sql('unnest(structured_withdrawal_reasons) as reason'))
        .group_by(&:itself)
        .transform_values(&:count)
    end

    def selectable_reasons
      YAML.load_file(CONFIG_PATH)
    end
  end
end
