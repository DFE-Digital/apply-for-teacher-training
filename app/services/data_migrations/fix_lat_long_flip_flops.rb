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

      audit_count = 0
      total_audits = audits.count

      Provider.find_each do |p|
        audits_for_provider = audits.where(auditable_id: p.id)

        # if we already had lat/lng when we made the first spurious update, delete every audit
        if audits_for_provider.first.audited_changes['latitude'].last.nil?
          audits_for_provider.destroy_all

        # otherwise, delete all the audits except the one that set it for the first time
        else

          audits_for_provider.where("audited_changes#>>'{longitude, 1}' is null").destroy_all
          audits_for_provider.where("audited_changes#>>'{longitude, 0}' is null").offset(1).destroy_all
        end

        audit_count += audits_for_provider.count
      end

      Rails.logger.info("Deleted #{audit_count} lat/long audits out of #{total_audits}")
    end
  end
end
