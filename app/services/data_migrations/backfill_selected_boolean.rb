module DataMigrations
  class BackfillSelectedBoolean
    TIMESTAMP = 20210517161321
    MANUAL_RUN = false

    def change
      ApplicationReference.feedback_provided.in_batches do |references_batch|
        references_batch.update_all(selected: true)
      end
    end
  end
end
