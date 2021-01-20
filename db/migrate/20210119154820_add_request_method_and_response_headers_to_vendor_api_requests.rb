class AddRequestMethodAndResponseHeadersToVendorAPIRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :vendor_api_requests, :request_method, :string
    add_column :vendor_api_requests, :response_headers, :jsonb

    post_request_path_regex = /\/(offer|conditions-not-met|confirm-conditions-met|reject|confirm-enrolment|generate|clear)$/

    VendorAPIRequest.where(request_method: nil).where.not(status_code: 404).find_each do |vendor_api_request|
      if vendor_api_request.request_path =~ post_request_path_regex
        request_method = 'POST'
      else
        request_method = 'GET'
      end

      vendor_api_request.update!(request_method: request_method)
    end
  end
end
