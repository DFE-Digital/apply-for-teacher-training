class RemoveUnusedImmigrationColumnsFromApplicationForm < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :application_forms, :immigration_status_details, :string }
    safety_assured { remove_column :application_forms, :immigration_entry_date, :date }
    safety_assured { remove_column :application_forms, :immigration_route, :string }
    safety_assured { remove_column :application_forms, :immigration_route_details, :string }
    safety_assured { remove_column :application_forms, :immigration_right_to_work, :boolean }
  end
end
