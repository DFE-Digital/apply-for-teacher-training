module DataMigrations
  class BackfillRestructuredImmigrationStatus
    TIMESTAMP = 20210915120515
    MANUAL_RUN = false

    def change
      ApplicationForm.where(
        recruitment_cycle_year: 2022,
        submitted_at: nil,
      ).find_each do |application_form|
        application_form.update!(personal_details_completed: false) unless application_form.british_or_irish?
      end
    end
  end
end
