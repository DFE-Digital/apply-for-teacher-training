module DataMigrations
  class SetMissingWorkHistoryStatusValues
    TIMESTAMP = 20231206202136
    MANUAL_RUN = false

    def change
      application_forms.each do |application_form|
        application_form.update(work_history_status: 'can_complete')
      end
    end

  private

    def application_forms
      ApplicationForm.where(work_history_status: nil)
                     .where(work_history_completed: true)
                     .where(recruitment_cycle_year: 2024)
    end
  end
end
