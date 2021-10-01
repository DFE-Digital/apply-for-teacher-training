module DataMigrations
  class BackfillWorkHistoryStatusForCurrentCycle
    TIMESTAMP = 20211001130340
    MANUAL_RUN = false

    def change
      ApplicationForm
      .joins(:application_work_experiences)
      .where(work_history_status: nil, feature_restructured_work_history: true, recruitment_cycle_year: 2021)
      .distinct
      .find_each(&:can_complete!)

      ApplicationForm
      .left_outer_joins(:application_work_experiences)
      .where(recruitment_cycle_year: 2021, work_history_status: nil, feature_restructured_work_history: true, application_work_experiences: { id: nil })
      .where.not(work_history_explanation: nil)
      .distinct
      .find_each(&:can_not_complete!)
    end
  end
end
