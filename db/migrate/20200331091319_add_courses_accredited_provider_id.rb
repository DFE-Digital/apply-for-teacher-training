class AddCoursesAccreditedProviderId < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :accredited_provider_id, :integer, null: true
  end
end
