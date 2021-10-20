module DataMigrations
  class BackfillCarriedOverApplicationsDegreesComplete
    TIMESTAMP = 20211020121755
    MANUAL_RUN = false

    def change
      degrees_with_missing_year = ApplicationQualification.degrees.where(start_year: nil)
                                                           .or(ApplicationQualification.degrees.where(award_year: nil))
      forms_with_incomplete_degrees = ApplicationForm
                                        .joins(:application_qualifications)
                                        .current_cycle
                                        .where(degrees_completed: true, submitted_at: nil)
                                        .merge(degrees_with_missing_year)

      forms_with_incomplete_degrees.update(degrees_completed: false)
    end
  end
end
