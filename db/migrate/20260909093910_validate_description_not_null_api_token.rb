class ValidateDescriptionNotNullAPIToken < ActiveRecord::Migration[8.1]
  def up
    validate_check_constraint :vendor_api_tokens, name: 'vendor_api_tokens_description_null'
    change_column_null :vendor_api_tokens, :description, false
    remove_check_constraint :vendor_api_tokens, name: 'vendor_api_tokens_description_null'
  end

  def down
    add_check_constraint :vendor_api_tokens, 'description IS NOT NULL', name: 'vendor_api_tokens_description_null', validate: false
    change_column_null :vendor_api_tokens, :description, true
  end
end
