class CreateChaserSents < ActiveRecord::Migration[6.0]
  def up
    drop_table :chasers_sents

    create_table :chasers_sent do |t|
      t.references :chased, null: false, polymorphic: true, index: true
      t.string :chaser_type, null: false
      t.timestamps
    end
  end

  def down
    drop_table :chasers_sent

    create_table :chasers_sents do |t|
      t.string :type
      t.integer :application_choice_id
      t.timestamps
    end
  end
end
