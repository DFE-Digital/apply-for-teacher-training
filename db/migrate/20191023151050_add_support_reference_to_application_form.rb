class AddSupportReferenceToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :support_reference, :string, limit: 10
  end
end
