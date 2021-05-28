module DataMigrations
  class BackfillOfferData
    TIMESTAMP = 20210525144145
    MANUAL_RUN = false

    CONDITION_STATUS = {
      recruited: :met,
      conditions_not_met: :unmet,
    }.freeze

    def change
      application_choices = ApplicationChoice.where.not(offered_at: nil)

      ActiveRecord::Base.no_touching do
        application_choices.each do |application_choice|
          next if Offer.exists?(application_choice: application_choice)

          offer = Offer.create!(application_choice: application_choice)
          conditions = application_choice.offer['conditions'].map do |condition|
            condition_details = { text: condition }
            condition_details.merge!(status: CONDITION_STATUS[application_choice.status.to_sym]) if CONDITION_STATUS.key?(application_choice.status.to_sym)
            condition_details
          end
          next unless conditions.any?

          offer.conditions.create_with(offer_id: offer.id,
                                       created_at: Time.zone.now,
                                       updated_at: Time.zone.now).insert_all!(conditions)
        end
      end
    end
  end
end
