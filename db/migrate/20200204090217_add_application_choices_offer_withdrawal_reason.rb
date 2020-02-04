class AddApplicationChoicesOfferWithdrawalReason < ActiveRecord::Migration[6.0]
  def change
    change_table :application_choices, bulk: true do |t|
      t.string :offer_withdrawal_reason
      t.datetime :offer_withdrawn_at
    end
  end
end
