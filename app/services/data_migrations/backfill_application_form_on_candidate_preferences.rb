module DataMigrations
  class BackfillApplicationFormOnCandidatePreferences
    TIMESTAMP = 20250716104848
    MANUAL_RUN = false

    def change
      # Tested on 13786 Candidate Preferences (production data) and this job took 18 seconds
      CandidatePreference.where(application_form: nil).includes(candidate: :application_forms).find_each do |preference|
        preference.update_columns(application_form_id: preference.candidate.current_application.id)
      end
    end
  end
end
