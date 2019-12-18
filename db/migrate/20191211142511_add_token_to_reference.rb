class AddTokenToReference < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :hashed_sign_in_token, :string
  end
end
