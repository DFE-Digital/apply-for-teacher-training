class RemoveUnusedSignInRelatedColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :authentication_tokens, :authenticable_id, :bigint
    remove_column :authentication_tokens, :authenticable_type, :string
  end
end
