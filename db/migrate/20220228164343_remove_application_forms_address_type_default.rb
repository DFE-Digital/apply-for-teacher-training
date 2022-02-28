class RemoveApplicationFormsAddressTypeDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_null :application_forms, :address_type, true
    change_column_default :application_forms, :address_type, from: 'uk', to: nil
  end
end
