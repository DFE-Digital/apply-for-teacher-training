class AddDisabilityDisclosureToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :disability_disclosure, :string
  end
end
