class AddUserIdAndUserTypeColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :authentication_tokens, :user_id, :bigint
    add_column :authentication_tokens, :user_type, :string
  end
end
