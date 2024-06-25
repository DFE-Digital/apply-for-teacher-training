module DataMigrations
  class UpdateDeclineByDefaultAtFromCurrentCycle
    TIMESTAMP = 20231204134841
    MANUAL_RUN = true

    def change
      records.each do |application_choice|
        application_choice.update_columns(
          decline_by_default_at: CycleTimetable.apply_deadline,
          decline_by_default_days: nil,
        )
      end
    end

    def records
      ApplicationChoice
      .joins(:application_form)
      .where('decline_by_default_at >= ?', CycleTimetable.find_opens)
      .where('decline_by_default_at < ?', CycleTimetable.apply_deadline)
      .where('application_forms.recruitment_cycle_year': 2024)
      .where.not(declined_by_default: true)
    end
  end
end
