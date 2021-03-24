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

      Provider.find_each do |p|
        Rails.logger.info("FixLatLongFlipFlops: cleaning up provider #{p.id} (#{p.name_and_code})")

        audits_for_provider = audits.where(auditable_id: p.id)
        audits_for_provider_count_before_cleanup = audits.where(auditable_id: p.id).count

        # if we already had lat/lng when we made the first spurious update, delete every audit
        if audits_for_provider.first.audited_changes['latitude'].last.nil?
          delete_audits(audits_for_provider)

        # otherwise, delete all the audits except the one that set it for the first time
        else

          delete_audits(
            audits_for_provider.where("audited_changes#>>'{longitude, 1}' is null"),
          )

          delete_audits(
            audits_for_provider.where("audited_changes#>>'{longitude, 0}' is null").offset(1),
          )
        end

        deleted_audit_count += (audits_for_provider_count_before_cleanup - audits_for_provider.count)
      end

      Rails.logger.info("Deleted #{deleted_audit_count} lat/long audits out of #{total_audits}")
    end

  private

    def delete_audits(audits)
      audits.destroy_all
    end
  end
end
