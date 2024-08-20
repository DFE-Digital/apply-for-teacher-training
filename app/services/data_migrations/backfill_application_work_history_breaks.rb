module DataMigrations
  class BackfillApplicationWorkHistoryBreaks < ActiveRecord::Migration[7.1]
    disable_ddl_transaction!

    TIMESTAMP = 20240819153131
    MANUAL_RUN = false

    def change
      batch = 0

      ApplicationWorkHistoryBreak.where(breakable_id: nil, breakable_type: nil).in_batches do |batch_work_breaks|
        batch_work_breaks.update_all("breakable_id = application_form_id, breakable_type = 'ApplicationForm'")
        sleep(0.01)
        batch += 1
        Rails.logger.info "Running batch: #{batch}"
      rescue ActiveRecord::StatementInvalid => e
        Rails.logger.info "Error: #{e.message}"
      end

      Rails.logger.info 'Finished!'
    end
  end
end
