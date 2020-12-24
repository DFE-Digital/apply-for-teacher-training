# frozen_string_literal: true

# Migration responsible for creating a table with activities
class CreateActivities < ActiveRecord::Migration[6.0]
  # Create table
  def self.up
    create_table :activities do |t|
      t.belongs_to :trackable, polymorphic: true
      t.belongs_to :owner, polymorphic: true
      t.string  :key
      t.text    :parameters

      t.timestamps
    end

    add_index :activities, %i[trackable_id trackable_type]
    add_index :activities, %i[owner_id owner_type]
  end

  # Drop table
  def self.down
    drop_table :activities
  end
end
