require 'google/cloud/bigquery'

BIG_QUERY_API_JSON_KEY = ENV['BIG_QUERY_API_JSON_KEY']

if BIG_QUERY_API_JSON_KEY.present?
  Google::Cloud::Bigquery.configure do |config|
    config.project_id  = 'becoming-a-teacher-apply'
    config.credentials = JSON.parse(BIG_QUERY_API_JSON_KEY)
  end

  Google::Cloud::Bigquery.new
end
