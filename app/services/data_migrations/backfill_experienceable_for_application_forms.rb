module DataMigrations
  class BackfillExperienceableForApplicationForms < ActiveRecord::Migration[7.1]
    disable_ddl_transaction!

    TIMESTAMP = 20240809162421
    MANUAL_RUN = true

    def change
      ApplicationExperience.where(experienceable_id: nil, experienceable_type: nil).in_batches do |batch_experiences|
        batch_experiences.update_all("experienceable_id = application_form_id, experienceable_type = 'ApplicationForm'")
        sleep(0.01)
      end
    end
  end
end
