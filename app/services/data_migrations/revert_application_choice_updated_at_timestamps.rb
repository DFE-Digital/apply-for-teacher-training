module DataMigrations
  class RevertApplicationChoiceUpdatedAtTimestamps
    TIMESTAMP = 20210319132110
    MANUAL_RUN = false

    def change
      ApplicationForm
      .joins(:audits)
      .where(
        "auditable_type = 'ApplicationForm' AND
        action = 'update' AND
        audited_changes#>>'{second_nationality, 0}' = '' AND
        audited_changes#>>'{second_nationality, 1}' is null
        AND audits.created_at between ? AND ?",
        Time.zone.local(2021, 3, 17, 12, 30),
        Time.zone.local(2021, 3, 17, 13),
      )
      .includes(:audits)
      .find_each do |application_form|
        audit = application_form.audits.where(
          "action = 'update' AND
          audited_changes#>>'{second_nationality, 0}' = '' AND
          audited_changes#>>'{second_nationality, 1}' is null
          AND audits.created_at between ? AND ?",
          Time.zone.local(2021, 3, 17, 12, 30),
          Time.zone.local(2021, 3, 17, 13),
        )

        application_form.application_choices.each do |application_choice|
          latest_application_choices_audits_created_at = application_choice.audits.order(:created_at).last.created_at

          if application_form.audits.order(:created_at).last == audit && latest_application_choice_audits_created_at < audit.created_at
            application_choice.update_column('updated_at', latest_application_choices_audits_created_at)
          end
        end
      end
    end
  end
end
