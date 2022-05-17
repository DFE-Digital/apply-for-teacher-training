module DataMigrations
  class BackfillTempSites
    TIMESTAMP = 20220517111432
    MANUAL_RUN = false

    def change
      CycleTimetable::CYCLE_DATES.each_key do |year|
        next if year == CycleTimetable.next_year

        Provider.all.each do |provider|
          migrate_temp_sites_for_courses(provider, year)
        end
      end
    end

  private

    def migrate_temp_sites_for_courses(provider, year)
      courses = TeacherTrainingPublicAPI::Course.where(
        year: year,
        provider_code: provider.code,
      ).paginate(per_page: 500)

      courses.each do |course|
        migrate_temp_sites_for_course(provider, course, year)
      end
    end

    def migrate_temp_sites_for_course(provider, course, year)
      sites = TeacherTrainingPublicAPI::Location.where(
        year: year,
        provider_code: provider.code,
        course_code: course.code,
      ).includes(:location_status).paginate(per_page: 500)

      sites.each do |site|
        temp_site = TeacherTrainingPublicAPI::AssignTempSiteAttributes.new(site, provider).call
        temp_site.save!
      end
    end
  end
end
