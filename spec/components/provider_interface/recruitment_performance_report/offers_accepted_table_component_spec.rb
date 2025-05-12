require 'rails_helper'

RSpec.describe ProviderInterface::RecruitmentPerformanceReport::OffersAcceptedTableComponent do
  it 'renders the report with expected columns and formats', :aggregate_failures do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics

    render_inline described_class.new(provider, provider_report.statistics, national_statistics)

    expect(page).to have_table('5. Offers accepted')
    expect(page).to have_content(description)

    expect(page).to have_content provider.name
    expect(page).to have_content 'All providers'
    expect(page).to have_content 'Subject'
    ['This cycle', 'Last cycle', 'Percentage change'].each do |heading|
      expect(page).to have_element('th', scope: 'col', class: 'govuk-table__header', text: heading).twice
    end

    primary_row = page.find('tr.govuk-table__row', text: 'Primary')
    expect(primary_row).to have_content '7'
    expect(primary_row).to have_content '7'
    expect(primary_row).to have_content '0%'
    expect(primary_row).to have_content '6,503'
    expect(primary_row).to have_content '7,115'
    expect(primary_row).to have_content '-9%'

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

private

  def secondary_subject_headings
    ['Art & Design',
     'Biology',
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

  def description
    'The table includes candidates who accepted and then deferred an offer from the provider in a previous cycle, which has been confirmed this cycle. It also includes candidates who accepted offers, but then did not meet the conditions of that offer.'
  end
end
