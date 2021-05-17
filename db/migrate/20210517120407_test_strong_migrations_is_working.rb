class TestStrongMigrationsIsWorking < ActiveRecord::Migration[6.1]
  def change
    add_column :references, :test_column, :boolean, default: false
  end
end
