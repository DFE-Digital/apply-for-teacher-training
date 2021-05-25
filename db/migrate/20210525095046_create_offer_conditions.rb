class CreateOfferConditions < ActiveRecord::Migration[6.1]
  def change
    create_table :offer_conditions do |t|
      t.references :offer, null: false, foreign_key: true
      t.string :text
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
