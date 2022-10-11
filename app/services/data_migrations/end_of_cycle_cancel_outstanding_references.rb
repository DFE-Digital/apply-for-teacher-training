module DataMigrations
  class EndOfCycleCancelOutstandingReferences
    TIMESTAMP = 20220913163416
    MANUAL_RUN = true
    RECRUITMENT_CYCLES = [2021, 2022]

    def change
      records.each do |record|
        record.update_columns(
          feedback_status: :cancelled_at_end_of_cycle,
          cancelled_at: Time.zone.now,
        )
      end
    end

    def dry_run
      "The total of #{records.count} references will be cancelled"

      "Double-check all recruitment cycle are in #{RECRUITMENT_CYCLES.join(' or ')}:"
      puts records.all? { |record| record.application_form.recruitment_cycle_year.in?(RECRUITMENT_CYCLES) }
    end

    def records
      ApplicationReference.joins(:application_form)
        .feedback_requested
        .where(
          application_form: {
            recruitment_cycle_year: RECRUITMENT_CYCLES,
          },
        )
    end
  end
end
