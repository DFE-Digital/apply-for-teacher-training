class AddSitesUuidNullCheckConstraint < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :sites, 'uuid IS NOT NULL', name: 'sites_uuid_null', validate: false
  end
end
