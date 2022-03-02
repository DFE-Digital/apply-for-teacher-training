require 'rails_helper'

RSpec.describe 'Monthly Statistics', type: :request do
  include StatisticsTestHelper

  around do |example|
    Timecop.freeze(2021, 11, 29) do
      example.run
    end
  end

  before do
    generate_statistics_test_data

    report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(month: '2021-11')
    report.load_table_data
    report.save
  end

  describe 'getting reports for different dates' do
    before do
      # assign the current numbers to the 2021-10 report so we can test retrieving that report
      report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(month: '2021-10')
      report.load_table_data
      report.save
    end

    it 'returns the report for 2021-11' do
      get '/publications/monthly-statistics/'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('to 22 November 2021')

      get '/publications/monthly-statistics/2021-10'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('to 18 October 2021')

      get '/publications/monthly-statistics/2021-11'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('to 22 November 2021')

      get '/publications/monthly-statistics/2021-12'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns application by status csv for 2021-10' do
      get '/publications/monthly-statistics/2021-10/applications_by_status.csv'
      expect(response).to have_http_status(:ok)
    end

    context 'when the "lock external report to January 2022" feature flag is on' do
      before do
        report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(month: '2022-01')
        report.load_table_data
        report.save

        FeatureFlag.activate('lock_external_report_to_january_2022')
      end

      it 'displays that month’s report' do
        get '/publications/monthly-statistics/'

        expect(response.body).to include('to 17 January 2022')
        expect(response).to have_http_status(:ok)
      end
    end
  end

  it 'returns application by status csv' do
    get '/publications/monthly-statistics/2021-11/applications_by_status.csv'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Status,First application,Apply again,Total'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns candidates by status csv' do
    get '/publications/monthly-statistics/2021-11/candidates_by_status'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Status,First application,Apply again,Total'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns candidates by age group csv' do
    get '/publications/monthly-statistics/2021-11/by_age_group'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Age group,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns applications by course age group csv' do
    get '/publications/monthly-statistics/2021-11/by_course_age_group'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Course phase,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns candidates by area csv' do
    get '/publications/monthly-statistics/2021-11/by_area'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Area,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns candidates by sex csv' do
    get '/publications/monthly-statistics/2021-11/by_sex'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Sex,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns applications by course type csv' do
    get '/publications/monthly-statistics/2021-11/by_course_type'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Course type,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns applications by primary specialist subject csv' do
    get '/publications/monthly-statistics/2021-11/by_primary_specialist_subject'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Subject,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns applications by secondary subject csv' do
    get '/publications/monthly-statistics/2021-11/by_secondary_subject'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Subject,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns applications by provider area csv' do
    get '/publications/monthly-statistics/2021-11/by_provider_area'
    expect(response).to have_http_status(:ok)
    expect(response.body).to start_with 'Area,Recruited,Conditions pending'
    expect(response.header['Content-Type']).to include 'text/csv'
  end

  it 'returns a 404 when an invalid date is in the URL' do
    get '/publications/monthly-statistics/foo-2021-11/by_provider_area'
    expect(response).to have_http_status(:not_found)
    expect(response.body).to include 'Page not found'
    expect(response.header['Content-Type']).not_to include 'text/csv'
  end
end
