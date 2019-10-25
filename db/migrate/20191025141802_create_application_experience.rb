class CreateApplicationExperience < ActiveRecord::Migration[6.0]
  def change
    create_table :application_experiences do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }

      t.string :type, null: false
      t.string :role, null: false
      t.string :organisation, null: false

      t.text :details, null: false

      t.boolean :working_with_children, null: false

      t.datetime :start_date, null: false
      t.datetime :end_date

      t.string :commitment

      t.timestamps
    end
  end
end
