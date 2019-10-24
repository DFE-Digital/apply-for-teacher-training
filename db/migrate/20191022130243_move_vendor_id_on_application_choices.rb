class MoveVendorIdOnApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    rename_column(:application_choices, :id, :vendor_id)
  end
end
