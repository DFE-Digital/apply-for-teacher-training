class CreateOriginalOfferSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :original_offer_snapshots do |t|
      t.references :offer, foreign_key: true
      t.references :course, foreign_key: true
      t.references :site, foreign_key: true
      t.string :study_mode
      t.string :conditions_status

      t.timestamps
    end
  end
end
