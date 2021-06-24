module DataMigrations
  class FixEmptyOfferConditions
    TIMESTAMP = 20210624092858
    MANUAL_RUN = false

    def change
      OfferCondition.where(text: '').find_each do |oc|
        offer = oc.offer
        application_choice = offer.application_choice

        if application_choice.status == 'pending_conditions' && offer.conditions.map(&:text).uniq == ['']
          application_choice.update!(status: 'recruited', audit_comment: 'Fixing empty offer conditions, the accepted offer was made unconditionally.')
        end

        oc.destroy!
      end
    end
  end
end
