class IndexToKindOnProviderUserFilters < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :provider_user_filters, :kind, algorithm: :concurrently
  end
end
