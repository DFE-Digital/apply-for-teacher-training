class AddAdviserStatusToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :adviser_status, :string, null: false, default: :unassigned
  end
end
