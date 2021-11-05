module MonthlyStatistics
  class Base
  protected

    def recruited_count(statuses)
      statuses['recruited'] || 0
    end

    def pending_count(statuses)
      statuses['pending_conditions'] || 0
    end

    def offer_count(statuses)
      (statuses['offer'] || 0) + (statuses['offer_deferred'] || 0)
    end

    def awaiting_decision_count(statuses)
      (statuses['awaiting_provider_decision'] || 0) + (statuses['interviewing'] || 0)
    end

    def unsuccessful_count(statuses)
      (statuses['declined'] || 0) +
        (statuses['rejected'] || 0) +
        (statuses['conditions_not_met'] || 0) +
        (statuses['withdrawn'] || 0) +
        (statuses['offer_withdrawn'] || 0)
    end

    def statuses_count(statuses)
      recruited_count(statuses) +
        pending_count(statuses) +
        offer_count(statuses) +
        awaiting_decision_count(statuses) +
        unsuccessful_count(statuses)
    end
  end
end
