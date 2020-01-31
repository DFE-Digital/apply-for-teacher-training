class CreateChasersSent < ActiveRecord::Migration[6.0]
  def change
    create_table :chasers_sents do |t|
      t.string :type
      t.integer :application_choice_id
      t.timestamps
    end
  end
end
