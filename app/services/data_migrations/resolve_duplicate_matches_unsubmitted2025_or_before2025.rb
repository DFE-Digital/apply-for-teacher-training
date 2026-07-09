module DataMigrations
  class ResolveDuplicateMatchesUnsubmitted2025OrBefore2025
    TIMESTAMP = 20260709134923
    MANUAL_RUN = false

    def change
      duplicate_matches = DuplicateMatch
        .joins(candidates: :application_forms)
        .where(resolved: false)
        .group('fraud_matches.id')
        .having(<<~SQL)
          (
            MAX(application_forms.recruitment_cycle_year) < 2025
            OR (
              MAX(application_forms.recruitment_cycle_year) = 2025
              AND MAX(
                CASE
                  WHEN application_forms.recruitment_cycle_year = 2025
                   AND application_forms.submitted_at IS NOT NULL
                  THEN 1
                  ELSE 0
                END
              ) = 0
            )
          )
        SQL

      duplicate_matches.update_all(resolved: true)
    end
  end
end
