module DataMigrations
  class BackfillRestucturedWorkHistoryBoolean
    TIMESTAMP = 20210525132306
    MANUAL_RUN = true

    def change
      ApplicationForm
        .left_outer_joins(:application_work_experiences)
        .where('application_experiences.id IS NOT NULL OR work_history_explanation is NOT NULL')
        .where(feature_restructured_work_history: true)
        .distinct
        .each { |application_form| application_form.update!(feature_restructured_work_history: false) }
      # there's 12 in the db hence no find each

      ApplicationForm
        .left_outer_joins(:application_work_experiences)
        .where('application_experiences.id IS NULL AND work_history_explanation is NULL')
        .where(feature_restructured_work_history: false)
        .distinct
        .find_each(batch_size: 100) { |application_form| application_form.update!(feature_restructured_work_history: true) }
      # there's 564 of these
    end
  end
end
