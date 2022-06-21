module DataMigrations
  class BackfillSitesFromTempSites
    TIMESTAMP = 20220620162528
    MANUAL_RUN = true

    def change
      TempSite.find_each do |temp_site|
        site = Site.create_or_find_by(
          temp_site.attributes.except('id', 'created_at', 'updated_at'),
        )
        temp_site.course_options.update_all(site_id: site.id)
      end
    end
  end
end
