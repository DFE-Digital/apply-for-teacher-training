require 'rails_helper'

RSpec.describe 'Vendor API reasons for rejection' do
  include VendorAPISpecHelpers

  let(:application_choice) do
    create_application_choice_for_currently_authenticated_provider({}, [:with_current_rejection_reasons]).tap do |ac|
      ac.structured_rejection_reasons['selected_reasons'] << {
        id: 'references', label: 'References',
        details: {
          id: 'references_details',
          text: 'We do not accept references from close family members, such as your mum.',
        }
      }
      ac.save!
    end
  end

  let(:returned_rejection_reasons) { parsed_response.dig('data', 'attributes', 'rejection', 'reason') }

  before do
    get_api_request "/api/v#{version}/applications/#{application_choice.id}"
  end

  %w[1.0 1.1 1.2 1.3].each do |api_version|
    context "for version #{api_version}" do
      let(:version) { api_version }

      it "returns the full rejection reasons, including ones that don't exist anymore" do
        expect(returned_rejection_reasons).to include('Quality of writing')
        expect(returned_rejection_reasons).to include('such as your mum')
      end
    end
  end
end
