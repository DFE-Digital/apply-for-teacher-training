module DataMigrations
  class CleanupApplicationExperiencesExperienceable < ActiveRecord::Migration[7.1]
    disable_ddl_transaction!

    TIMESTAMP = 20240813173942
    MANUAL_RUN = false

    def change
      batch = 0
      ApplicationExperience.where(experienceable_id: nil, experienceable_type: nil).in_batches do |batch_experiences|
        batch_experiences.update_all("experienceable_id = application_form_id, experienceable_type = 'ApplicationForm'")
        sleep(0.01)
        batch += 1
        Rails.logger.info "Running batch: #{batch}"
      rescue ActiveRecord::StatementInvalid => e
        Rails.logger.info "Error: #{e.message}"
      end
    end
  end
end
