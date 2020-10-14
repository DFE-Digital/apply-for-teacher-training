class CreateDataExports < ActiveRecord::Migration[6.0]
  def change
    create_table :data_exports do |t|
      t.string :name
      t.binary :data
      t.datetime :completed_at
      t.references :initiator, null: true, polymorphic: true, index: true
      t.timestamps
    end
  end
end
