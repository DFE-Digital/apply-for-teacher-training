class AddResidencyFieldsToApplicationForm < ActiveRecord::Migration[8.0]
  def change
    add_column :application_forms, :country_residency_date_from, :date
    add_column :application_forms, :country_residency_since_birth, :boolean
  end
end
