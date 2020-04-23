class AddAgeRangeToCourse < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :age_range, :string
  end
end
