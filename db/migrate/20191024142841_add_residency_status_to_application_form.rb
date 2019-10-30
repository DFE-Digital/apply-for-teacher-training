class AddResidencyStatusToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :uk_residency_status, :string
  end
end
