class AddTypeToProviders < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :provider_type, :string
  end
end
