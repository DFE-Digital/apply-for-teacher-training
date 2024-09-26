module DataMigrations
  class SetDeclineByDefaultAtAndDeclineByDefaultDaysToNil
    TIMESTAMP = 20240925092609
    MANUAL_RUN = true

    def change
      application_choices.in_batches(of: 4000) do |batch|
        batch.update_all(decline_by_default_at: nil, decline_by_default_days: nil)
      end
    end

  private

    def application_choices
      choices_from_2024
        .where.not(decline_by_default_at: nil)
        .or(choices_from_2024.where.not(decline_by_default_days: nil))
        .distinct
    end

    def choices_from_2024
      @choices_from_2024 ||= ApplicationChoice
                               .joins(:application_form)
                               .where('application_form.recruitment_cycle_year': 2024)
                               .distinct
    end
  end
end
