class AddCoursesAccreditedProviderId < ActiveRecord::Migration[6.0]
  def up
    return if column_exists?(:courses, :accredited_provider_id)

    add_column :courses, :accredited_provider_id, :integer, null: true
  end

  def down
    remove_column :courses, :accredited_provider_id
  end
end
