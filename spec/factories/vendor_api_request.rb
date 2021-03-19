FactoryBot.define do
  factory :vendor_api_request do
    provider
    request_path { '/api/v1/applications' }
    request_method { 'GET' }
    status_code { 200 }
    request_headers { {} }
    request_body { {} }
    response_headers { {} }
    response_body { {} }
    created_at { Time.zone.now }
  end
end
