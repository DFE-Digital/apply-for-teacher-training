class MakeUserIdAndUserTypeNotNullableAndAddIndex < ActiveRecord::Migration[6.0]
  def change
    change_column_null :authentication_tokens, :user_id, false
    change_column_null :authentication_tokens, :user_type, false
    add_index :authentication_tokens, %i[user_id user_type], name: 'index_authentication_tokens_on_id_and_type'
  end
end
