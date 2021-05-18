module DataMigrations
  class BackfillReferencesCompletedBoolean
    TIMESTAMP = 20210518144653
    MANUAL_RUN = false

    def change
      ApplicationForm
      .joins(:application_references)
      .where(application_references: { feedback_status: :feedback_provided })
      .group('application_forms.id')
      .having('count(application_references) >= ?', 2)
      .find_in_batches do |batch|
        batch.each do |application_form|
          application_form.update!(references_completed: true)
        end
      end
    end
  end
end
