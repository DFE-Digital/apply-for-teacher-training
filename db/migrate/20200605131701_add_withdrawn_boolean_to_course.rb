class AddWithdrawnBooleanToCourse < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :withdrawn, :boolean
  end
end
