class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :message
      t.belongs_to :application_choice, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :provider_user, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
