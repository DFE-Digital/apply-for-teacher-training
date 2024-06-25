class RemoveUkResidencyStatusFromApplicationForms < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :application_forms, :uk_residency_status, :string
    end
  end
end
