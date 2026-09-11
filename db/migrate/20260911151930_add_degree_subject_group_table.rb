class AddDegreeSubjectGroupTable < ActiveRecord::Migration[8.1]
  def change
    create_table :degree_subject_groups do |t|
      t.string :name
      t.string :subject_group_uuid
      t.references :application_qualification, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
