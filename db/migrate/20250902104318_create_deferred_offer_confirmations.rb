class CreateDeferredOfferConfirmations < ActiveRecord::Migration[8.0]
  def change
    create_table :deferred_offer_confirmations do |t|
      t.references :provider_user, null: false, foreign_key: true
      t.references :offer, null: false, foreign_key: true
      t.references :course, null: true, foreign_key: true
      t.references :site, null: true, foreign_key: true
      t.string :study_mode, null: true
      t.string :conditions_status, null: true
      t.timestamps
    end
  end
end
