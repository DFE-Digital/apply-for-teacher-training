module DataMigrations
  class BackfillReferencesCompleted
    TIMESTAMP = 20210726160211
    MANUAL_RUN = false

    def change
      ApplicationForm.where.not(submitted_at: nil).where(references_completed: nil).in_batches do |forms|
        forms.update_all(references_completed: true)
      end
    end
  end
end
