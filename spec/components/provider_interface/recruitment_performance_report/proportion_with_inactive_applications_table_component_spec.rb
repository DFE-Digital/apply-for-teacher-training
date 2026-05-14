require 'rails_helper'

RSpec.describe RecruitmentPerformanceReport::ProportionWithInactiveApplicationsTableComponent do
  it 'renders the report with expected columns and formats', :aggregate_failures do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics

    render_inline described_class.new(provider, provider_report.statistics, national_statistics)

    expect(page).to have_table('7. Proportion of candidates who have waited more than 30 working days for a response')
    expect(page).to have_text(description(provider.name))
    expect(page).to have_text('Subject')

    expect(page).to have_text provider.name
    expect(page).to have_text 'All providers'
    expect(page).to have_text 'Subject'
    ['This cycle', 'Last cycle'].each do |heading|
      expect(page).to have_element('th', scope: 'col', class: 'govuk-table__header', text: heading).twice
    end

    %w[Primary Secondary].each do |heading|
      expect(page).to have_element('th', scope: 'row', class: 'govuk-table__header', text: heading)
    end

    expect(page).to have_no_text 'Percentage change'

    primary_row = page.find('tr.govuk-table__row', text: 'Primary')
    expect(primary_row).to have_text '7%'
    expect(primary_row).to have_text '24%'

    secondary_subject_headings.each do |heading|
      expect(page).to have_element(
        'th',
        scope: 'row',
        class: 'govuk-table__header recruitment-performance-report-table__cell--secondary-subject',
        text: heading,
      )
    end
  end

  it 'renders the report with expected columns previous cycle', :aggregate_failures do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics
    previous_cycle_year = RecruitmentCycleTimetable.previous_year

    render_inline described_class.new(
      provider,
      provider_report.statistics,
      national_statistics,
      recruitment_cycle_year: previous_cycle_year,
    )

    expect(page).to have_table('7. Proportion of candidates who have waited more than 30 working days for a response')
    expect(page).to have_text(description(provider.name))
    expect(page).to have_text('Subject')

    expect(page).to have_text provider.name
    expect(page).to have_text 'All providers'
    expect(page).to have_text 'Subject'

    [
      "#{previous_cycle_year} cycle",
      "#{previous_cycle_year - 1} cycle",
    ].each do |heading|
      expect(page).to have_element('th', scope: 'col', class: 'govuk-table__header', text: heading).twice
    end

    %w[Primary Secondary].each do |heading|
      expect(page).to have_element('th', scope: 'row', class: 'govuk-table__header', text: heading)
    end

    expect(page).to have_no_text 'Percentage change'

    primary_row = page.find('tr.govuk-table__row', text: 'Primary')
    expect(primary_row).to have_text '7%'
    expect(primary_row).to have_text '24%'

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
    %w[Drama Others]
  end

  def description(provider_name)
    "This table shows the proportion of candidates who have waited for 30 working days or more for #{provider_name} to respond to their application."
  end
end
