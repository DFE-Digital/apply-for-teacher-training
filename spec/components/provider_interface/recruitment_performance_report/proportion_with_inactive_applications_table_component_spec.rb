require 'rails_helper'

RSpec.describe ProviderInterface::RecruitmentPerformanceReport::ProportionWithInactiveApplicationsTableComponent do
  it 'renders the report with expected columns and formats', :aggregate_failures do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics

    render_inline described_class.new(provider, provider_report.statistics, national_statistics)

    expect(page).to have_table('8. Proportion of candidates who have waited more than 30 days for a response')
    expect(page).to have_content(description(provider.name))
    expect(page).to have_content('Subject')

    [provider.name, 'All providers'].each do |heading|
      expect(page).to have_element(
        'th',
        scope: 'col',
        class: 'govuk-table__header govuk-table__header--numeric recruitment-performance-report-table-subheading',
        text: heading,
      )
    end

    %w[Primary Secondary].each do |heading|
      expect(page).to have_element('th', scope: 'row', class: 'govuk-table__header', text: heading)
    end

    primary_row = page.find('tr.govuk-table__row', text: 'Primary')
    expect(primary_row).to have_content '7%'
    expect(primary_row).to have_content '24%'

    secondary_subject_headings.each do |heading|
      expect(page).to have_element(
        'th',
        scope: 'row',
        class: 'govuk-table__header recruitment-performance-report-table-subject-rows__secondary-subject-row-heading',
        text: heading,
      )
    end
  end

private

  def secondary_subject_headings
    %w[Drama Others]
  end

  def description(provider_name)
    "The proportion of candidates who have waited for 30 days or more for #{provider_name} to respond to their application, compared with national level data."
  end
end
