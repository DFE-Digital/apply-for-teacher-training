class CreateDeletedEntities < ActiveRecord::Migration[8.1]
  def change
    create_table :deleted_entities do |t|
      t.bigint :entity_id, null: false
      t.string :entity_name, null: false
      t.jsonb :deleted_records, null: false

      t.timestamps
    end
  end
end
