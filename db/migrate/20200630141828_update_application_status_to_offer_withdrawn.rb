class UpdateApplicationStatusToOfferWithdrawn < ActiveRecord::Migration[6.0]
  def change
    ApplicationChoice
      .where(status: 'rejected')
      .where.not(offer_withdrawn_at: nil)
      .each do |application_choice|
        application_choice.update!(
          status: 'offer_withdrawn',
          audit_comment: 'Data migration to introduce the "offer_withdrawn" state',
        )
      end
  end
end
