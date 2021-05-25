module DataMigrations
  class BackfillOfferData
    TIMESTAMP = 20210525144145
    MANUAL_RUN = false

    def change
      application_choices = ApplicationChoice.where.not(offered_at: nil)

      ActiveRecord::Base.no_touching do
        application_choices.each do |application_choice|
          offer = Offer.new(application_choice: application_choice)
          application_choice.offer['conditions'].each do |condition|
            offer.conditions.build(text: condition)
          end
          offer.save
        end
      end
    end
  end
end
