module DataMigrations
  class FixLatLongFlipFlops
    TIMESTAMP = 20210323203521
    MANUAL_RUN = true

    def change
      log("Before: audits table size is #{audits_table_size}")

      Audited::Audit.connection.execute("DELETE FROM audits WHERE (auditable_type = 'Provider' AND action = 'update' AND audited_changes ?& array['latitude', 'longitude'] AND (audited_changes - 'latitude') - 'longitude' = '{}')")

      log("After: audits table size is #{audits_table_size}")
    end

    def log(message)
      log_string = %w[FixLatLongFlipFlops]
      log_string << '-'
      log_string << message

      Rails.logger.info log_string.join(' ')
    end

    def audits_table_size
      query = "SELECT pg_size_pretty(pg_total_relation_size('audits'));"
      ActiveRecord::Base.connection.execute(query).first['pg_size_pretty']
    end
  end
end
