require 'rails_helper'

RSpec.describe RecruitmentPerformanceReport::SubmittedApplicationsTableComponent do
  it 'renders the report with expected columns and formats', :aggregate_failures do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics

    render_inline described_class.new(provider, provider_report.statistics, national_statistics)

    expect(page).to have_table('2. Candidates who have submitted applications')

    expect(page).to have_content provider.name
    expect(page).to have_content 'All providers'
    expect(page).to have_content 'Subject'
    ['This cycle', 'Last cycle', 'Percentage change'].each do |heading|
      expect(page).to have_element('th', scope: 'col', class: 'govuk-table__header', text: heading).twice
    end

    %w[Primary Secondary].each do |heading|
      expect(page).to have_element('th', scope: 'row', class: 'govuk-table__header', text: heading)
    end

    primary_row = page.find('tr.govuk-table__row', text: 'Primary')
    expect(primary_row).to have_content '15'
    expect(primary_row).to have_content '58'
    expect(primary_row).to have_content '-74%'
    expect(primary_row).to have_content '13,214'
    expect(primary_row).to have_content '13,364'
    expect(primary_row).to have_content '-1%'

    secondary_subject_headings.each do |heading|
      expect(page).to have_element(
        'th',
        scope: 'row',
        class: 'govuk-table__header recruitment-performance-report-table__cell--secondary-subject',
        text: heading,
      )
    end
  end

  describe 'provider report only has secondary data' do
    it 'does not render primary data' do
      provider_report = create(:provider_recruitment_performance_report, :secondary_only)
      provider = provider_report.provider
      national_statistics = create(:national_recruitment_performance_report).statistics

      render_inline described_class.new(provider, provider_report.statistics, national_statistics)

      expect(page).to have_table('2. Candidates who have submitted applications')
      expect(page).to have_element('th', scope: 'row', class: 'govuk-table__header', text: 'Secondary')
      expect(page).not_to have_element('th', scope: 'row', class: 'govuk-table__header', text: 'Primary')
      secondary_subject_headings.each do |heading|
        expect(page).to have_element(
          'th',
          scope: 'row',
          class: 'govuk-table__header recruitment-performance-report-table__cell--secondary-subject',
          text: heading,
        )
      end
    end
  end

  describe 'provider report only has' do
    it 'does not render secondary data' do
      provider_report = create(:provider_recruitment_performance_report, :primary_only)
      provider = provider_report.provider
      national_statistics = create(:national_recruitment_performance_report).statistics

      render_inline described_class.new(provider, provider_report.statistics, national_statistics)

      expect(page).to have_table('2. Candidates who have submitted applications')
      expect(page).to have_element('th', scope: 'row', class: 'govuk-table__header', text: 'Primary')

      expect(page).not_to have_element('th', scope: 'row', class: 'govuk-table__header', text: 'Secondary')
      secondary_subject_headings.each do |heading|
        expect(page).not_to have_element(
          'th',
          scope: 'row',
          class: 'govuk-table__header app-table__header--padding-left',
          text: heading,
        )
      end
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
end
