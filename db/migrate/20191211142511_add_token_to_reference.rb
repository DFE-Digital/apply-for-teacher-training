class AddTokenToReference < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :token, :string
  end
end
