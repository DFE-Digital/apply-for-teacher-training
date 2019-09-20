class RemoveAccreditedBodyCodeFromCourses < ActiveRecord::Migration[5.2]
  def change
    remove_column :courses, :accredited_body_code, :string
  end
end
