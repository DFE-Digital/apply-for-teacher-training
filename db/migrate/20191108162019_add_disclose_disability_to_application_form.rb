class AddDiscloseDisabilityToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :disclose_disability, :boolean, null: true
  end
end
