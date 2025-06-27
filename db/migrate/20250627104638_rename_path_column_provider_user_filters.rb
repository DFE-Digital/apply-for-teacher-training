class RenamePathColumnProviderUserFilters < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      rename_column :provider_user_filters, :path, :kind
    end
  end
end
