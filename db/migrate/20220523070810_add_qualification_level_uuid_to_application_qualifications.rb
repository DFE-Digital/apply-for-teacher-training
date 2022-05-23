class AddQualificationLevelUuidToApplicationQualifications < ActiveRecord::Migration[7.0]
  def change
    add_column :application_qualifications, :qualification_level_uuid, :uuid
  end
end
