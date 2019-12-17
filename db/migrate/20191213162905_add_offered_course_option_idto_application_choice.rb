class AddOfferedCourseOptionIdtoApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :offered_course_option_id, :integer, index: true
    add_foreign_key :application_choices, :course_options, column: :offered_course_option_id
  end
end
