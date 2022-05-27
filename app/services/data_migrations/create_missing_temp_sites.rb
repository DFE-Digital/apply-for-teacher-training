module DataMigrations
  class CreateMissingTempSites
    TIMESTAMP = 20220525161544
    MANUAL_RUN = true

    def change
      CourseOption.where(temp_site: nil).each do |course_option|
        course_option.update(
          temp_site: find_or_create_temp_site(
            course_option.site,
            course_option.course.recruitment_cycle_year,
          ),
        )
      end
    end

  private

    def find_or_create_temp_site(site, cycle)
      matching_temp_site(site, cycle) || create_temp_site(site)
    end

    def matching_temp_site(site, cycle)
      TempSite
        .joins(course_options: :course)
        .where(code: site.code, provider: site.provider)
        .where(courses: { recruitment_cycle_year: cycle })
        .first
    end

    def create_temp_site(site)
      additional_attrs = { uuid: SecureRandom.uuid, uuid_generated_by_apply: true }
      TempSite.create(site.attributes.except(%w[id created_at updated_at]).merge(additional_attrs))
    end
  end
end
