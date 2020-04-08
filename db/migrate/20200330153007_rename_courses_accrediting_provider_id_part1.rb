class RenameCoursesAccreditingProviderIdPart1 < ActiveRecord::Migration[6.0]
  def up
    unless column_exists?(:courses, :accredited_provider_id)
      add_column :courses, :accredited_provider_id, :integer, null: true
    end

    execute 'UPDATE courses SET accredited_provider_id = accrediting_provider_id'
  end

  def down; end
end
