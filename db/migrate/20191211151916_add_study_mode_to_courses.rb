class AddStudyModeToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :study_mode, :string, limit: 1, null: false, default: 'F'
  end
end
