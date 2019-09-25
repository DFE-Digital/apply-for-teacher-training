class CreateApplicationForms < ActiveRecord::Migration[6.0]
  def change
    create_table :application_forms do |t|
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
