module DataMigrations
  class EndOfCycleCancelOutstandingReferences
    TIMESTAMP = 20220913163416
    MANUAL_RUN = true
    RECRUITMENT_CYCLE_YEAR = 2022
    PHASE = 'apply_2'.freeze

    def change
      records.each do |record|
        record.update!(
          feedback_status: :cancelled_at_end_of_cycle,
          cancelled_at: Time.zone.now,
        )
        RefereeMailer.reference_cancelled_email(record).deliver_later
      end
    end

    def dry_run
      "The total of #{records.count} references will be cancelled"
    end

    def records
      ApplicationReference.joins(:application_form)
        .feedback_requested
        .where(
          application_form: {
            recruitment_cycle_year: RECRUITMENT_CYCLE_YEAR,
            phase: PHASE,
          },
        )
        .where(application_form: { id: ApplicationChoice
            .where(status: 'unsubmitted')
            .select('application_form_id') })
    end
  end
end
