class CreateApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    create_table :application_choices do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }
      t.text :personal_statement

      t.string :provider_ucas_code
      t.string :course_ucas_code
      t.string :location_ucas_code

      t.timestamps
    end
  end
end
