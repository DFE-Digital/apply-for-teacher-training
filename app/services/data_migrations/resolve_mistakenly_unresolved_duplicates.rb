module DataMigrations
  class ResolveMistakenlyUnresolvedDuplicates
    TIMESTAMP = 20260709184810
    MANUAL_RUN = true

    def change
      duplicates.update_all(resolved: true)
    end

    def dry_run
      [
        duplicates.count, # Should be about 10334
        duplicates.pluck(:id).includes(11910), # Should be false
        duplicates.pluck(:id).include?(11909), # Should be false
      ]
    end

  private

    def duplicates
      @duplicates ||= DuplicateMatch
        .where(resolved: false)
        .where('updated_at > ?',Time.zone.local(2026, 7, 9, 15, 21)) # Should be'2026-07-09 14:20:21.0 +0100',
        .where('updated_at < ?', Time.zone.local(2026, 7, 9, 16, 21)) # Should be'2026-07-09 15:20:21.0 +0100',
    end
  end
end
