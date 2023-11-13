require 'rails_helper'

RSpec.describe 'Monthly Statistics', time: Time.zone.local(2022, 11, 29) do
  include StatisticsTestHelper

  let(:temporarily_unavailable) { '/publications/monthly-statistics/temporarily-unavailable' }

  before do
    generate_statistics_test_data

    new_report(
      month: '2022-11',
      generation_date: Date.new(2022, 11, 22),
      publication_date: Date.new(2022, 11, 28),
    )

    new_report(
      month: '2022-09',
      generation_date: Date.new(2022, 9, 19),
      publication_date: Date.new(2022, 9, 26),
    )
  end

  describe 'getting reports for different dates' do
    before do
      # assign the current numbers to the 2022-10 report so we can test retrieving that report
      report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(
        month: '2022-10',
        generation_date: Date.new(2022, 10, 18),
        publication_date: Date.new(2022, 10, 24),
      )
      report.load_table_data
      report.save
    end

    context 'with monthly statistics redirect disabled' do
      before do
        FeatureFlag.deactivate(:monthly_statistics_redirected)
      end

      it 'renders the report for 2022-11' do
        get '/publications/monthly-statistics/'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('to 22 November 2022')

        get '/publications/monthly-statistics/2022-10'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('to 18 October 2022')

        get '/publications/monthly-statistics/2022-11'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('to 22 November 2022')

        get '/publications/monthly-statistics/2022-12'
        expect(response).to have_http_status(:not_found)
      end

      it 'returns application by status csv for 2022-10' do
        get '/publications/monthly-statistics/2022-10/applications_by_status.csv'
        expect(response).to have_http_status(:ok)
      end

      it '404s for a badly formatted date' do
        get '/publications/monthly-statistics/12-23'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with monthly statistics redirect enabled' do
      before do
        FeatureFlag.activate(:monthly_statistics_redirected)
      end

      it 'renders the report for 2022-11' do
        get '/publications/monthly-statistics/'
        expect(response).to redirect_to(temporarily_unavailable)
        get temporarily_unavailable
        expect(response.body).to include('The first publication of ITT statistics for the new cycle will be on Monday 27 November 2023.')
        expect(response.body).to include('https://www.gov.uk/government/publications/monthly-statistics-on-initial-teacher-training-recruitment-2023-to-2024')
        expect(response.body).to include('becomingateacher@digital.education.gov.uk')

        get '/publications/monthly-statistics/2022-10'
        expect(response).to redirect_to(temporarily_unavailable)

        get '/publications/monthly-statistics/2022-11'
        expect(response).to redirect_to(temporarily_unavailable)

        get '/publications/monthly-statistics/2022-12'
        expect(response).to redirect_to(temporarily_unavailable)
      end

      it 'returns application by status csv for 2022-10' do
        get '/publications/monthly-statistics/2022-10/applications_by_status.csv'
        expect(response).to redirect_to(temporarily_unavailable)
      end

      it '404s for a badly formatted date' do
        get '/publications/monthly-statistics/12-23'
        expect(response).to redirect_to(temporarily_unavailable)
      end
    end
  end

  context 'with monthly statistics redirect enabled' do
    before do
      FeatureFlag.activate(:monthly_statistics_redirected)
    end

    it 'returns the latest application for old cycles' do
      get '/publications/monthly-statistics/ITT2022'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('to 19 September 2022')
    end

    it 'returns the latest application for new cycle' do
      get '/publications/monthly-statistics/ITT2023'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns a 404 when an old date is in the URL' do
      get '/publications/monthly-statistics/ITT2002'
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'Page not found'
      expect(response.header['Content-Type']).not_to include 'text/csv'
    end

    it 'returns a 404 when an invalid date is in the URL params' do
      get '/publications/monthly-statistics/foo-2022-11'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns application by status csv' do
      get '/publications/monthly-statistics/2022-11/applications_by_status.csv'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns candidates by status csv' do
      get '/publications/monthly-statistics/2022-11/candidates_by_status'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns candidates by age group csv' do
      get '/publications/monthly-statistics/2022-11/by_age_group'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns applications by course age group csv' do
      get '/publications/monthly-statistics/2022-11/by_course_age_group'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns candidates by area csv' do
      get '/publications/monthly-statistics/2022-11/by_area'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns candidates by sex csv' do
      get '/publications/monthly-statistics/2022-11/by_sex'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns applications by course type csv' do
      get '/publications/monthly-statistics/2022-11/by_course_type'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns applications by primary specialist subject csv' do
      get '/publications/monthly-statistics/2022-11/by_primary_specialist_subject'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns applications by secondary subject csv' do
      get '/publications/monthly-statistics/2022-11/by_secondary_subject'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns applications by provider area csv' do
      get '/publications/monthly-statistics/2022-11/by_provider_area'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'returns a 404 when an invalid date is in the URL' do
      get '/publications/monthly-statistics/foo-2022-11/by_provider_area'
      expect(response).to redirect_to(temporarily_unavailable)
    end
  end

  context 'with monthly statistics redirect disabled' do
    before do
      FeatureFlag.deactivate(:monthly_statistics_redirected)
    end

    it 'returns the latest application for old cycles' do
      get '/publications/monthly-statistics/ITT2022'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('to 19 September 2022')
    end

    it 'returns the latest application for new cycle' do
      get '/publications/monthly-statistics/ITT2023'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('to 22 November 2022')
    end

    it 'returns a 404 when an old date is in the URL' do
      get '/publications/monthly-statistics/ITT2002'
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'Page not found'
      expect(response.header['Content-Type']).not_to include 'text/csv'
    end

    it 'returns a 404 when an invalid date is in the URL params' do
      get '/publications/monthly-statistics/foo-2022-11'
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'Page not found'
      expect(response.header['Content-Type']).not_to include 'text/csv'
    end

    it 'returns application by status csv' do
      get '/publications/monthly-statistics/2022-11/applications_by_status.csv'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Status,First application,Apply again,Total'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns candidates by status csv' do
      get '/publications/monthly-statistics/2022-11/candidates_by_status'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Status,First application,Apply again,Total'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns candidates by age group csv' do
      get '/publications/monthly-statistics/2022-11/by_age_group'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Age group,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns applications by course age group csv' do
      get '/publications/monthly-statistics/2022-11/by_course_age_group'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Course phase,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns candidates by area csv' do
      get '/publications/monthly-statistics/2022-11/by_area'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Area,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns candidates by sex csv' do
      get '/publications/monthly-statistics/2022-11/by_sex'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Sex,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns applications by course type csv' do
      get '/publications/monthly-statistics/2022-11/by_course_type'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Course type,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns applications by primary specialist subject csv' do
      get '/publications/monthly-statistics/2022-11/by_primary_specialist_subject'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Subject,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns applications by secondary subject csv' do
      get '/publications/monthly-statistics/2022-11/by_secondary_subject'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Subject,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns applications by provider area csv' do
      get '/publications/monthly-statistics/2022-11/by_provider_area'
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with 'Area,Recruited,Conditions pending'
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'returns a 404 when an invalid date is in the URL' do
      get '/publications/monthly-statistics/foo-2022-11/by_provider_area'
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'Page not found'
      expect(response.header['Content-Type']).not_to include 'text/csv'
    end
  end

  def new_report(options)
    report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(options)
    report.load_table_data
    report.save
  end
end
