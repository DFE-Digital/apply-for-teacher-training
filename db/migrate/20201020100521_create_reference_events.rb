class CreateReferenceEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :reference_events do |t|
      t.string :name, null: false
      t.belongs_to :application_reference, null: false, foreign_key: { to_table: :references, on_delete: :cascade }
      t.timestamps
    end
  end
end
