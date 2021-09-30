module DataMigrations
  class BackfillWorkHistoryStatus
    TIMESTAMP = 20210930132233
    MANUAL_RUN = false

    def change
      ApplicationForm
      .joins(:application_work_experiences)
      .where(recruitment_cycle_year: 2022, work_history_status: nil)
      .distinct
      .find_each(&:can_complete!)

      ApplicationForm
      .left_outer_joins(:application_work_experiences)
      .where(recruitment_cycle_year: 2022, work_history_status: nil, application_work_experiences: { id: nil })
      .where.not(work_history_explanation: nil)
      .find_each(&:can_not_complete!)
    end
  end
end
