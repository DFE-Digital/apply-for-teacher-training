class AddTypeToReference < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :type, :string
  end
end
