module DataMigrations
  class DestroyOrphanedSites
    TIMESTAMP = 20220620110204
    MANUAL_RUN = true

    def change
      orphaned_sites = Site.where.missing(:course_options).distinct
      orphaned_sites.destroy_all
    end
  end
end
