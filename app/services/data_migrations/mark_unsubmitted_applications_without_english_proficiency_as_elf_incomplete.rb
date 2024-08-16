module DataMigrations
  class MarkUnsubmittedApplicationsWithoutEnglishProficiencyAsElfIncomplete
    TIMESTAMP = 20240816134619
    MANUAL_RUN = false

    def change
      problem_application_forms.update_all(
        efl_completed: false, efl_completed_at: nil,
      )
    end

    def problem_application_forms
      ApplicationForm
        .current_cycle
        .unsubmitted
        .where.missing(:english_proficiency)
        .where(efl_completed: true)
    end
  end
end
