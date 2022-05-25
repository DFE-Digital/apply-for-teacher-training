module DataMigrations
  class CreateMissingTempSites
    TIMESTAMP = 20220525161544
    MANUAL_RUN = true

    def change
      Site
        .left_joins(:course_options)
        .where.not(course_options: { id: nil })
        .distinct
        .each do |site|
          temp_site = create_corresponding_temp_site_if_none_existing(site)
          attach_temp_site_to_course_options(site, temp_site)
        end
    end

  private

    def create_corresponding_temp_site_if_none_existing(site)
      unless matching_temp_site?(site)
        additional_attrs = { uuid: SecureRandom.uuid, uuid_generated_by_apply: true }
        TempSite.create(site.attributes.except(%w[id created_at updated_at]).merge(additional_attrs))
      end
    end

    def attach_temp_site_to_course_options(site, temp_site)
      site.course_options.each do |course_option|
        course_option.update(temp_site: temp_site)
      end
    end

    def matching_temp_site?(site)
      TempSite.find_by(code: site.code, provider: site.provider).present?
    end
  end
end
