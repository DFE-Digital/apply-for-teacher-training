module DataMigrations
  class SetHideInReportingToFalseAfter2022
    TIMESTAMP = 20260429101756
    MANUAL_RUN = false

    def change
      Candidate.joins(:application_forms)
        .where('application_forms.recruitment_cycle_year >= ? and candidates.hide_in_reporting = ?', 2022, true)
        .update_all(hide_in_reporting: false)
    end
  end
end
