class DropSitesReferences < ActiveRecord::Migration[7.0]
  def change
    remove_index :course_options, name: 'index_course_options_on_site_id', column: %i[site_id]
    remove_index :course_options, name: 'index_course_options_on_site_id_and_course_id_and_study_mode', column: %i[site_id course_id study_mode]
    safety_assured { remove_column :course_options, :site_id, :bigint }
    remove_index :sites, name: 'index_sites_on_code_and_provider_id', column: %i[code provider_id]
    remove_index :sites, name: 'index_sites_on_provider_id', column: %i[provider_id]
  end
end
