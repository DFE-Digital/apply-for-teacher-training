class CreateServiceBanners < ActiveRecord::Migration[8.0]
  def change
    create_table :service_banners do |t|
      t.string :header
      t.string :body
      t.string :interface
      t.string :status, default: 'draft', null: false

      t.timestamps
    end
  end
end
