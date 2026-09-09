class SetDescriptionNotNullAPIToken < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :vendor_api_tokens, 'description IS NOT NULL', name: 'vendor_api_tokens_description_null', validate: false
  end
end
