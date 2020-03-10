class AddCourseLengthStartDateAndAppOpenFromToCourse < ActiveRecord::Migration[6.0]
  def change
    change_table :courses, bulk: true do |t|
      t.datetime :start_date
      t.datetime :apply_from_date
      t.string :course_length
    end
  end
end
