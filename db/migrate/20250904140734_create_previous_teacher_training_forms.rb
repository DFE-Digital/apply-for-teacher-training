class CreatePreviousTeacherTrainingForms < ActiveRecord::Migration[8.0]
  def change
    create_table :previous_teacher_training_forms do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }
      t.string :choice
      t.string :provider_name
      t.datetime :started_at
      t.datetime :ended_at
      t.text :details

      t.timestamps
    end
  end
end
