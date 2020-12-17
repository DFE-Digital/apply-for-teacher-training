class MakeAuthenticableIdAndTypeColumnsNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :authentication_tokens, :authenticable_id, true
    change_column_null :authentication_tokens, :authenticable_type, true
  end
end
