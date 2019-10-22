class AlterApplicationChoicesToReferenceCourseOptions < ActiveRecord::Migration[6.0]
  def change
    remove_reference :application_choices, :course
    add_reference :application_choices, :course_option, null: false, foreign_key: true
  end
end
