class CreateVendorAPIRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :vendor_api_requests do |t|
      t.string    :request_path
      t.jsonb     :request_headers
      t.jsonb     :request_body
      t.jsonb     :response_body
      t.integer   :status_code
      t.bigint    :response_time
      t.string    :hashed_token

      t.timestamps
    end
  end
end
