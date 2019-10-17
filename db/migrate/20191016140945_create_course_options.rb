class CreateCourseOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :course_options do |t|
      t.references :site, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.string :vacancy_status, null: false

      t.timestamps
    end

    add_index :course_options, %i[site_id course_id], unique: true
  end
end
