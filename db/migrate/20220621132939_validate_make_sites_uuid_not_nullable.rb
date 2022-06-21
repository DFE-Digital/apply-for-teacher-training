class ValidateMakeSitesUuidNotNullable < ActiveRecord::Migration[7.0]
  def change
    validate_check_constraint :sites, name: 'sites_uuid_null'
    safety_assured { change_column_null :sites, :uuid, false }
    remove_check_constraint :sites, name: 'sites_uuid_null'
  end
end
