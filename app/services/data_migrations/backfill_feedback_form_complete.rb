module DataMigrations
  class BackfillFeedbackFormComplete
    TIMESTAMP  = 20230612071351
    MANUAL_RUN = false

    def change
      applications.find_each(batch_size: 500) do |batch|
        batch.update_columns(feedback_form_complete: true)
      end
    end

  private

    def applications
      ApplicationForm.where.not(feedback_satisfaction_level: nil)
                     .or(ApplicationForm.where.not(feedback_suggestions: nil))
    end
  end
end
