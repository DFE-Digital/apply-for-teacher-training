require 'rails_helper'

RSpec.describe 'Monthly Statistics', type: :request do
  include StatisticsTestHelper
  let(:current_date) { [2021, 11, 29] }

  let(:temporarily_unavailable) { '/publications/monthly-statistics/temporarily-unavailable' }

  around do |example|
    Timecop.freeze(*current_date) do
      example.run
    end
  end

  before do
    generate_statistics_test_data

    report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(
      month: '2021-11',
      generation_date: Date.new(2021, 11, 22),
      publication_date: Date.new(2021, 11, 29),
    )
    report.load_table_data
    report.save
  end

  describe 'getting reports for different dates' do
    before do
      # assign the current numbers to the 2021-10 report so we can test retrieving that report
      report = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(
        month: '2021-10',
        generation_date: Date.new(2021, 10, 18),
        publication_date: Date.new(2021, 10, 25),
      )
      report.load_table_data
      report.save
    end

    it 'redirects the report for 2021-11' do
      get '/publications/monthly-statistics/'
      expect(response).to redirect_to(temporarily_unavailable)
      get temporarily_unavailable
      expect(response.body).to include('The first publication of ITT statistics for the new cycle will be on Monday 28 November 2022.')
      expect(response.body).to include('https://www.gov.uk/government/publications/monthly-statistics-on-initial-teacher-training-itt-recruitment')
      expect(response.body).to include('becomingateacher@digital.education.gov.uk')

      get '/publications/monthly-statistics/2021-10'
      expect(response).to redirect_to(temporarily_unavailable)

      get '/publications/monthly-statistics/2021-11'
      expect(response).to redirect_to(temporarily_unavailable)

      get '/publications/monthly-statistics/2021-12'
      expect(response).to redirect_to(temporarily_unavailable)
    end

    it 'redirects application by status csv for 2021-10' do
      get '/publications/monthly-statistics/2021-10/applications_by_status.csv'
      expect(response).to redirect_to(temporarily_unavailable)
    end
  end

  it 'redirects application by status csv' do
    get '/publications/monthly-statistics/2021-11/applications_by_status.csv'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects candidates by status csv' do
    get '/publications/monthly-statistics/2021-11/candidates_by_status'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects candidates by age group csv' do
    get '/publications/monthly-statistics/2021-11/by_age_group'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects applications by course age group csv' do
    get '/publications/monthly-statistics/2021-11/by_course_age_group'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects candidates by area csv' do
    get '/publications/monthly-statistics/2021-11/by_area'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects candidates by sex csv' do
    get '/publications/monthly-statistics/2021-11/by_sex'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects applications by course type csv' do
    get '/publications/monthly-statistics/2021-11/by_course_type'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects applications by primary specialist subject csv' do
    get '/publications/monthly-statistics/2021-11/by_primary_specialist_subject'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects applications by secondary subject csv' do
    get '/publications/monthly-statistics/2021-11/by_secondary_subject'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects applications by provider area csv' do
    get '/publications/monthly-statistics/2021-11/by_provider_area'
    expect(response).to redirect_to(temporarily_unavailable)
  end

  it 'redirects a 404 when an invalid date is in the URL' do
    get '/publications/monthly-statistics/foo-2021-11/by_provider_area'
    expect(response).to redirect_to(temporarily_unavailable)
  end
end
