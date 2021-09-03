class AddNewRightToWorkColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :application_forms, :immigration_right_to_work, :bool
    add_column :application_forms, :immigration_status, :string
    add_column :application_forms, :immigration_status_details, :string
    add_column :application_forms, :immigration_entry_date, :date
    add_column :application_forms, :immigration_route, :string
    add_column :application_forms, :immigration_route_details, :string
  end
end
