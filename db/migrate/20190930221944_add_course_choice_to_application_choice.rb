class AddCourseChoiceToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_reference :application_choices, :course_choice
    remove_column :application_choices, :provider_ucas_code, :string, null: false
    remove_column :application_choices, :course_ucas_code, :string, null: false
    remove_column :application_choices, :location_ucas_code, :string, null: false
  end
end
