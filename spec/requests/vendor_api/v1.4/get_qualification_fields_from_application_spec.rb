require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.4/applications' do
  include VendorAPISpecHelpers

  let(:application_choice) { create_application_choice_for_currently_authenticated_provider }
  let!(:gcse_qualification) do
    create(
      :gcse_qualification,
      currently_completing_qualification: true,
      missing_explanation: 'I will be taking an equivalency test in a few weeks',
      other_uk_qualification_type: 'Equivalency test',
      application_form: application_choice.application_form,
    )
  end

  before do
    get_api_request "/api/v1.4/applications/#{application_choice.id}"
  end

  describe 'get completing qualifications fields' do
    it 'returns the correct GCSEs fields' do
      gcses = parsed_response['data']['attributes']['qualifications']['gcses']
      gcse = gcses.find { |item| item['id'] == gcse_qualification.public_id }

      expect(gcse['currently_completing_qualification']).to be true
      expect(gcse['missing_explanation']).to eq 'I will be taking an equivalency test in a few weeks'
      expect(gcse['other_uk_qualification_type']).to eq 'Equivalency test'
    end
  end
end
