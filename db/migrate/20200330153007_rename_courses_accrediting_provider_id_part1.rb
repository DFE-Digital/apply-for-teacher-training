class RenameCoursesAccreditingProviderIdPart1 < ActiveRecord::Migration[6.0]
  def up
    add_column :courses, :accredited_provider_id, :integer, null: true
    execute 'UPDATE courses SET accredited_provider_id = accrediting_provider_id'
  end

  def down
    remove_column :courses, :accredited_provider_id
  end
end
