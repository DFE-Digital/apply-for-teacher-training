class AddPathColumnToAuthenticationTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :authentication_tokens, :path, :string
  end
end
