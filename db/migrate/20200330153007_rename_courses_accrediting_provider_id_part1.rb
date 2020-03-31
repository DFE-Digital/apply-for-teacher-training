class RenameCoursesAccreditingProviderIdPart1 < ActiveRecord::Migration[6.0]
  def up
    execute 'UPDATE courses SET accredited_provider_id = accrediting_provider_id'
  end

  def down; end
end
