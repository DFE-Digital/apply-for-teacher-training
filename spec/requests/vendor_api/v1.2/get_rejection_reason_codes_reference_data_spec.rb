require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.2/reference-data/rejection-reason-codes' do
  include VendorAPISpecHelpers

  before do
    get_api_request '/api/v1.2/reference-data/rejection-reason-codes'
  end

  it 'returns a response that is valid according to the OpenAPI schema' do
    expect(parsed_response).to be_valid_against_draft_openapi_schema('ObjectListResponse')
  end

  it 'lists all rejection reason codes' do
    expect(parsed_response['data'].map { |hash| hash['code'] }).to eq(VendorAPI::RejectionReasons::CODES.keys)
  end

  it 'lists all rejection reason labels' do
    expect(parsed_response['data'].map { |hash| hash['label'] }).to eq(VendorAPI::RejectionReasons::CODES.values.map { |v| v[:label] })
  end

  it 'lists all rejection reason default details text' do
    expect(parsed_response['data'].map { |hash| hash['default_details'] }).to eq(
      VendorAPI::RejectionReasons::CODES.values.map { |v| v.dig(:details, :text) },
    )
  end
end
