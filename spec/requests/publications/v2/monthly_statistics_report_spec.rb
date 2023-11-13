require 'rails_helper'

RSpec.describe 'V2 Monthly Statistics', time: Time.zone.local(2023, 11, 29) do
  let(:temporarily_unavailable) { '/publications/monthly-statistics/temporarily-unavailable' }

  # TODO: complete this when implementing month and csv

  describe 'publications/monthly-statistics/ITT(:year) when year is >= 2024' do
    context 'when monthly statistics redirect is enabled' do
      before do
        FeatureFlag.activate(:monthly_statistics_redirected)
      end

      it 'renders the report for 2024-11' do
        get '/publications/monthly-statistics/ITT2024'
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(temporarily_unavailable)
      end
    end

    context 'when monthly statistics redirect is disabled' do
      before do
        FeatureFlag.deactivate(:monthly_statistics_redirected)
      end

      it 'renders the report for 2024-11' do
        get '/publications/monthly-statistics/ITT2024'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('These statistics cover applications for courses in England starting in the 2024 to 2025 academic year')
      end
    end
  end
end
