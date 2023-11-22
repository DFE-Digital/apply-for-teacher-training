module DataMigrations
  class RemoveDbdFromCurrentCycle
    TIMESTAMP = 20231122153455
    MANUAL_RUN = true

    def change
      records.each do |application_choice|
        application_choice.update_columns(
          declined_by_default: false,
          decline_by_default_days: nil,
          declined_at: nil,
          status: 'offer',
        )
      end
    end

    def records
      ApplicationChoice.where(
        declined_by_default: true,
        current_recruitment_cycle_year: 2024,
      ).reject do |application_choice|
        application_choice.application_form.application_choices.offer.any? { |ac| ac.course_option == application_choice.course_option } ||
          application_choice.application_form.any_offer_accepted?
      end
    end
  end
end
