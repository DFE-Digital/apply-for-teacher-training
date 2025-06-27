class AddIndexToProviderPoolAction < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :provider_pool_actions, %i[status recruitment_cycle_year actioned_by_id], algorithm: :concurrently
  end
end
