require 'rails_helper'

RSpec.describe 'V2 Monthly Statistics', time: Time.zone.local(2023, 11, 29) do
  let(:temporarily_unavailable) { '/publications/monthly-statistics/temporarily-unavailable' }

  before do
    create(
      :monthly_statistics_report,
      :v2,
      month: '2023-11',
      generation_date: Time.zone.local(2023, 11, 20),
      publication_date: Time.zone.local(2023, 11, 27),
    )
  end

  describe 'publications/monthly-statistics/ITT(:year) when year is >= 2024' do
    context 'when monthly statistics redirect is enabled' do
      before do
        FeatureFlag.activate(:monthly_statistics_redirected)
      end

      context 'when latest report' do
        before { get '/publications/monthly-statistics' }

        it 'redirects to temporarily unavailable' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(temporarily_unavailable)
        end
      end

      context 'when get specific month' do
        before { get '/publications/monthly-statistics/2023-11' }

        it 'redirects to temporarily unavailable' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(temporarily_unavailable)
        end
      end

      context 'when get specific year' do
        before { get '/publications/monthly-statistics/ITT2024' }

        it 'redirects to temporarily unavailable' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(temporarily_unavailable)
        end
      end

      context 'when downloading' do
        before { get '/publications/monthly-statistics/2023-11/candidate_age_group.csv' }

        it 'redirects to temporarily unavailable' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(temporarily_unavailable)
        end
      end
    end

    context 'when monthly statistics redirect is disabled' do
      before do
        FeatureFlag.deactivate(:monthly_statistics_redirected)
      end

      it 'renders a list of reports and next expected generation date' do
        get '/publications/monthly-statistics'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('These reports contain data collected during the 2023 to 2024 recruitment cycle for applications in the academic year starting in September 2024. Statistics covering the 2022 to 2023 recruitment cycle, for courses starting in the 2023 to 2024 are also included to allow for comparison.')
        expect(response.body).to include('Expected 25 December 2023')
      end

      it 'renders the latest report for 2024' do
        get '/publications/monthly-statistics/ITT2024'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('This report contains data collected during the 2023 to 2024 recruitment cycle for applications in the academic year starting in September 2024.')
      end

      it 'renders 404 for future cycles' do
        get '/publications/monthly-statistics/ITT2025'
        expect(response).to have_http_status(:not_found)
      end

      it 'renders the report for 2023-11' do
        get '/publications/monthly-statistics/2023-11'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('This report contains data collected during the 2023 to 2024 recruitment cycle for applications in the academic year starting in September 2024.')
      end

      it 'returns application by age group csv for 2023-11' do
        get '/publications/monthly-statistics/2023-11/candidate_age_group.csv'
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(
          "Age Group,Submitted this cycle,Submitted last cycle,With offers this cycle,With offers last cycle,Accepted this cycle,Accepted last cycle,All applications rejected this cycle,All applications rejected last cycle,Reconfirmed from previous cycle this cycle,Reconfirmed from previous cycle last cycle,Deferred this cycle,Deferred last cycle,Withdrawn this cycle,Withdrawn last cycle,Offer conditions not met this cycle,Offer conditions not met last cycle\n21,400,200,598,567,20,10,100,50,285,213,0,0,200,100,30,15\n",
        )
      end

      it 'renders 404 for invalid export type' do
        get '/publications/monthly-statistics/2023-11/one_does_not_simply_tries_to_download_something_that_does_not_exist.csv'
        expect(response).to have_http_status(:not_found)
      end

      it '404s for a badly formatted date' do
        get '/publications/monthly-statistics/12-23'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
