class AddCourseAndSiteToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_reference :application_choices, :course, null: false, foreign_key: true
  end
end
