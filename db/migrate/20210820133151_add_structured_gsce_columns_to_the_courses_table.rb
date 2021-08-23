class AddStructuredGsceColumnsToTheCoursesTable < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :accept_pending_gcse, :boolean
    add_column :courses, :accept_gcse_equivalency, :boolean
    add_column :courses, :accept_english_gcse_equivalency, :boolean
    add_column :courses, :accept_maths_gcse_equivalency, :boolean
    add_column :courses, :accept_science_gcse_equivalency, :boolean
    add_column :courses, :additional_gcse_equivalencies, :string
  end
end
