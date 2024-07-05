module DataMigrations
  class BackfillExperienceableOnApplicationExperiences
    TIMESTAMP = 20240705154708
    MANUAL_RUN = false

    def change
      ApplicationExperience.where(experienceable_id: nil, experienceable_type: nil).in_batches do |batch_experiences|
        batch_experiences.update_all("experienceable_id = application_form_id, experienceable_type = 'ApplicationForm'")
      end
    end
  end
end
