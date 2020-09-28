class CreateVendorAPIRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :vendor_api_requests do |t|
      t.string :request_path
      t.integer :status_code
      t.string :hashed_token
      t.jsonb :request_headers
      t.jsonb :request_body
      t.jsonb :response_body
      t.bigint :response_time
      t.datetime :created_at
    end
  end
end
