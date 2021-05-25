class CreateOffers < ActiveRecord::Migration[6.1]
  def change
    create_table :offers do |t|
      t.references :application_choice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
