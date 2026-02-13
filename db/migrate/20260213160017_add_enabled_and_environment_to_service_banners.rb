class AddEnabledAndEnvironmentToServiceBanners < ActiveRecord::Migration[8.0]
  def change
    add_column :service_banners, :enabled, :boolean, default: false, null: false
    add_column :service_banners, :environment, :string
  end
end
