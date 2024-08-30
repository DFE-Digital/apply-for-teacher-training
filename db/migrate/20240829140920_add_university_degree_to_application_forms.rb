class AddUniversityDegreeToApplicationForms < ActiveRecord::Migration[7.1]
  def change
    add_column :application_forms, :university_degree, :boolean
  end
end
