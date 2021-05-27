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

          offer = Offer.new(application_choice: application_choice)
          application_choice.offer['conditions'].each do |condition|
            condition_details = { text: condition }
            condition_details.merge!(status: CONDITION_STATUS[application_choice.status.to_sym]) if CONDITION_STATUS.key?(application_choice.status.to_sym)
            offer.conditions.build(condition_details)
          end
          offer.save
        end
      end
    end
  end
end
