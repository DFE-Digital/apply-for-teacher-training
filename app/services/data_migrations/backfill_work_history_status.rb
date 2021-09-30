module DataMigrations
  class BackfillWorkHistoryStatus
    TIMESTAMP = 20210930132233
    MANUAL_RUN = false

    def change
      ApplicationForm
      .joins(:application_work_experiences)
      .where(recruitment_cycle_year: 2022, work_history_status: nil)
      .where.not(application_work_experiences: { id: nil })
      .distinct
      .each(&:can_complete!)
    end
  end
end
