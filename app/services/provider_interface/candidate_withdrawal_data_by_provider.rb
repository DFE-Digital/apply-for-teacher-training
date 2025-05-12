module ProviderInterface
  class CandidateWithdrawalDataByProvider
    CONFIG_PATH = 'config/withdrawal_reasons.yml'.freeze

    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end

    def submitted_withdrawal_reason_count
      current_cycle_applications_visible_to_provider
        .where.not(structured_withdrawal_reasons: [])
        .count
    end

    def withdrawal_data
      selectable_reasons.map do |reason|
        before_acceptance_count = withdrawal_query[['withdrawn_before_acceptance', reason[:id]]] || 0
        after_acceptance_count = withdrawal_query[['withdrawn_after_acceptance', reason[:id]]] || 0
        total_count = before_acceptance_count + after_acceptance_count

        {
          header: reason[:label],
          values: [
            before_acceptance_count,
            after_acceptance_count,
            total_count,
          ],
        }
      end
    end

  private

    def withdrawal_query
      current_cycle_applications_visible_to_provider
        .pluck(Arel.sql('CASE WHEN accepted_at IS NULL THEN \'withdrawn_before_acceptance\' ELSE \'withdrawn_after_acceptance\' END AS withdrawal_status, unnest(structured_withdrawal_reasons) as reason'))
        .group_by(&:itself)
        .transform_values(&:count)
    end

    def current_cycle_applications_visible_to_provider
      ApplicationChoice
        .where('provider_ids @> ARRAY[?]::bigint[]', provider)
        .where(current_recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
    end

    def selectable_reasons
      YAML.load_file(CONFIG_PATH)
    end
  end
end
