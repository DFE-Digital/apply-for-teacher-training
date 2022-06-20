class AddSiteToCourseOptions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :course_options, :site_id, :bigint
    add_foreign_key :course_options, :sites, on_delete: :cascade, validate: false
    add_index :course_options, %i[site_id course_id study_mode], unique: true, algorithm: :concurrently
    add_index :course_options, %i[site_id], algorithm: :concurrently
  end
end
