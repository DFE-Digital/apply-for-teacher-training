module DataMigrations
  class FixLatLongFlipFlops
    TIMESTAMP = 20210323203521
    MANUAL_RUN = true

    def change
      audits = Audited::Audit.where(
        "auditable_type = 'Provider' AND
        action = 'update' AND
        audited_changes ?& array['latitude', 'longitude'] AND
        (audited_changes - 'latitude') - 'longitude' = '{}'",
      ).order(created_at: :asc)

      deleted_audit_count = 0
      total_audits = audits.count

      log("Before: audits table size is #{audits_table_size}")

      providers.find_each do |p|
        log("Cleaning up provider #{p.id} (#{p.name_and_code})")

        audits_for_provider = audits.where(auditable_id: p.id)
        audits_for_provider_count_before_cleanup = audits.where(auditable_id: p.id).count

        if audits_for_provider.empty?
          log("No audits to clean up for provider #{p.id}")
          next
        end

        # if we already had lat/lng when we made the first spurious update, delete every audit
        if audits_for_provider.first.audited_changes['latitude'].last.nil?
          delete_audits(
            'lat/long-only audits for this provider (all of them) becase lat/long was set beforehand',
            audits_for_provider,
          )

        # otherwise, delete all the audits except the one that set it for the first time
        else

          delete_audits(
            'audits which set the lat/long to nil',
            audits_for_provider.where("audited_changes#>>'{longitude, 1}' is null"),
          )

          delete_audits(
            'audits which repeatedly set the lat/long to the same value',
            audits_for_provider.where("audited_changes#>>'{longitude, 0}' is null").offset(1),
          )
        end

        deleted_audit_count += (audits_for_provider_count_before_cleanup - audits_for_provider.count)
      end

      log("Deleted #{deleted_audit_count} lat/long audits out of #{total_audits}") unless dry_run?

      log("After: audits table size is #{audits_table_size}")
    end

  private

    def providers
      if dry_run?
        Provider.where(sync_courses: true).limit(50)
      else
        Provider.all
      end
    end

    def delete_audits(description, audits)
      log("Deleting #{audits.count} #{description}")
      audits.destroy_all unless dry_run?
    end

    def dry_run?
      ENV.fetch('FIX_LAT_LONG_DRY_RUN', 'true') == 'true'
    end

    def log(message)
      log_string = %w[FixLatLongFlipFlops]
      log_string << '(dry run)' if dry_run?
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
