module DataMigrations
  class RevertApplicationChoicesUpdatedAt
    TIMESTAMP = 20240923111225
    MANUAL_RUN = true

    def change(limit: nil, provider_ids: [], stagger_over: 5)
      BatchDelivery.new(relation: choices(limit, provider_ids), stagger_over: stagger_over.hours, batch_size: 1000).each do |next_batch_time, choices|
        RevertApplicationChoicesUpdatedAtWorker.perform_at(next_batch_time, choices.pluck(:id))
      end
    end

    def choices(limit, provider_ids)
      choices = ApplicationChoice
        .where(updated_at: Date.new(2024, 9, 3).all_day)
        .where.not(created_at: Date.new(2024, 9, 3).all_day)
        .where(current_recruitment_cycle_year: [2024, 2023])
        .where(status: ApplicationStateChange.states_visible_to_provider)

      if provider_ids.present?
        choices = choices.where(provider_ids:)
      end

      choices.limit(limit)
    end
  end
end
