module DataMigrations
  class ResolveDuplicateMatchesFrom2024AndEarlier
    TIMESTAMP = 20260708135913
    MANUAL_RUN = false

    def change
      duplicate_match_ids = DuplicateMatch
        .joins(candidates: :application_forms)
        .where(resolved: false)
        .group(:id)
        .having('MAX(application_forms.updated_at) < ?', Date.new(2024, 9, 30))
        .pluck(:id)

      DuplicateMatch
        .where(id: duplicate_match_ids)
        .update_all(resolved: true)
    end
  end
end
