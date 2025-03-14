class AddFiltersToProviderUser < ActiveRecord::Migration[8.0]
  def change
    add_column :provider_users, :find_a_candidate_filters, :jsonb, default: {}
  end
end
