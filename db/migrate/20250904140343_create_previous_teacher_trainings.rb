class CreatePreviousTeacherTrainings < ActiveRecord::Migration[8.0]
  def change
    create_table :previous_teacher_trainings do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }
      t.references :provider, null: true, foreign_key: true
      t.string :status, null: false, default: 'draft'
      t.string :started
      t.string :provider_name
      t.datetime :started_at
      t.datetime :ended_at
      t.text :details

      t.timestamps
    end
  end
end
