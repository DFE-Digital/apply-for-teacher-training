module DataMigrations
  class BackfillEqualityAndDiversityCompletedAttributes
    TIMESTAMP = 20230606115559
    MANUAL_RUN = true

    def change
      applications.find_each(batch_size: 500) do |application|
        application.update_columns(equality_and_diversity_completed: true, equality_and_diversity_completed_at: application.submitted_at)
      end
    end

  private

    def applications
      ApplicationForm
        .where.not(equality_and_diversity: nil)
        .where.not(submitted_at: nil)
        .where(equality_and_diversity_completed: nil)
    end
  end
end
