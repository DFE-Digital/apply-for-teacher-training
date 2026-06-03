module DataMigrations
  class NormalizeNamesOnApplicationForm
    TIMESTAMP = 20260602110000
    MANUAL_RUN = false

    def change
      ActiveRecord::Base.connection.execute(<<~SQL)
        UPDATE application_forms
        SET first_name = TRIM(first_name),
            last_name  = TRIM(last_name)
        WHERE (first_name <> TRIM(first_name)
            OR last_name  <> TRIM(last_name))
          AND recruitment_cycle_year IN (2025, 2026);
      SQL
    end
  end
end
