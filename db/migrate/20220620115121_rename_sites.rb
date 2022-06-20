class RenameSites < ActiveRecord::Migration[7.0]
  def change
    safety_assured { rename_column :course_options, :temp_site_id, :site_id }
    safety_assured { rename_table :temp_sites, :sites }
  end
end
