module DataMigrations
  class BackfillMissingGcseData
    TIMESTAMP = 20210913222950
    MANUAL_RUN = false

    def change
      ApplicationQualification
      .joins(:application_form)
      .where(application_form: { recruitment_cycle_year: 2022 })
      .where(level: 'gcse')
      .where.not(missing_explanation: nil)
      .each do |missing_gcse|
        missing_explanation = missing_gcse.missing_explanation
        missing_gcse.update!(currently_completing_qualification: true, not_completed_explanation: missing_explanation, missing_explanation: nil)
        missing_gcse.application_form.update!("#{missing_gcse.subject}_gcse_completed": false)
      end
    end
  end
end
