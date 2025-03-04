require 'rails_helper'

RSpec.describe ProviderInterface::RecruitmentPerformanceReport::CandidatesWithOffersTableComponent do
  it 'renders the report with expected columns and formats' do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics

    render_inline described_class.new(provider, provider_report.statistics, national_statistics)

    expect(page).to have_table('3. Candidates that received an offer')
    expect(page).to have_content(description(provider.name))

    expect(page).to have_content provider.name
    expect(page).to have_content 'All providers'
    expect(page).to have_content 'Subject'
    ['This cycle', 'Last cycle', 'Percentage change'].each do |heading|
      expect(page).to have_element('th', scope: 'col', class: 'govuk-table__header', text: heading).twice
    end

    primary_row = page.find('tr.govuk-table__row', text: 'Primary')
    expect(primary_row).to have_content '8'
    expect(primary_row).to have_content '8'
    expect(primary_row).to have_content '0%'
    expect(primary_row).to have_content '7,311'
    expect(primary_row).to have_content '7,949'
    expect(primary_row).to have_content '-8%'

    %w[Primary Secondary].each do |heading|
      expect(page).to have_element('th', scope: 'row', class: 'govuk-table__header', text: heading)
    end

    secondary_subject_headings.each do |heading|
      expect(page).to have_element(
        'th',
        scope: 'row',
        class: 'govuk-table__header recruitment-performance-report-table__cell--secondary-subject',
        text: heading,
      )
    end
  end

  def secondary_subject_headings
    ['Art & Design',
     'Biology',
     'Design & Technology',
     'English',
     'Geography',
     'History',
     'Mathematics',
     'Music',
     'Others',
     'Physical Education',
     'Physics',
     'Religious Education']
  end

  def description(provider_name)
    "This table shows candidates who have received one or more offers from #{provider_name} so far this recruitment cycle."
  end
end
