require 'rails_helper'

RSpec.describe VendorApi::ApplicationsController, type: :request do
  context 'given two providers with 100 applications in various states' do
    let(:current_provider) { create(:provider, code: 'BAT') }
    let(:other_provider) { create(:provider, code: 'DIFFERENT') }
    let(:api_token) { VendorApiToken.create_with_random_token!(provider: current_provider) }

    before do
      GenerateTestData.new(100, current_provider).generate
    end

    describe 'calling the index for all results in the last 2 years' do
      let(:calling_the_index) {
        get '/api/v1/applications.json', params: { since: 2.years.ago.to_date },
                                         headers: { 'Authorization' => "Token #{api_token}" }
      }

      it 'returns a 200 status' do
        calling_the_index
        expect(response.code).to eq('200')
      end

      it 'runs in less than 0.5s' do
        expect { calling_the_index }.to perform_under(0.5).sec
      end
    end
  end
end
