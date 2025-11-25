module DataMigrations
  class RemoveDuplicateSiteCodeFeatureFlag
    TIMESTAMP = 20251125170530
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :handle_duplicate_sites_test)&.destroy
    end
  end
end
