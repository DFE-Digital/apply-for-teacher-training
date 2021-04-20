class RemoveSubjectCodesFromCourse < ActiveRecord::Migration[6.0]
  def change
    remove_column :courses, :subject_codes, :jsonb
  end
end
