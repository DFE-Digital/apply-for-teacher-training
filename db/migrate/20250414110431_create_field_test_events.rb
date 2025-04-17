class CreateFieldTestEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :field_test_events do |t|
      t.references :field_test_membership
      t.string :name
      t.datetime :created_at
    end
  end
end
