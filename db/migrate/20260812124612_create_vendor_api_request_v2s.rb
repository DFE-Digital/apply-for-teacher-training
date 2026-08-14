class CreateVendorAPIRequestV2s < ActiveRecord::Migration[8.1]
  def change
    create_table :vendor_api_request_v2s do |t|
      t.references :provider, null: true
      t.jsonb :request_body
      t.jsonb :request_headers
      t.string :request_method
      t.string :request_path
      t.jsonb :response_body
      t.jsonb :response_headers
      t.integer :status_code
      t.index :status_code
      t.index :request_path
      t.datetime :created_at, precision: nil
    end
  end
end
