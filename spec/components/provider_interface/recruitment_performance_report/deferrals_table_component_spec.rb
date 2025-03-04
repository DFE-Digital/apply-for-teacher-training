require 'rails_helper'

RSpec.describe ProviderInterface::RecruitmentPerformanceReport::DeferralsTableComponent do
  it 'renders the report with expected columns and formats', :aggregate_failures do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics

    render_inline described_class.new(provider, provider_report.statistics, national_statistics)

    expect(page).to have_table('6. Deferrals')
    expect(page).to have_content(description(provider.name))

    [provider.name, 'All providers'].each do |heading|
      expect(page).to have_element(
        'th',
        scope: 'col',
        class: 'govuk-table__header govuk-table__header--numeric recruitment-performance-report-table__subheading',
        text: heading,
      )
    end

    this_cycle = page.find('tr.govuk-table__row', text: 'Deferrals this cycle (so far) to next cycle')
    expect(this_cycle).to have_content '0'
    expect(this_cycle).to have_content '514'

    last_cycle = page.find('tr.govuk-table__row', text: 'Deferrals from last cycle to this cycle')
    expect(last_cycle).to have_content '0'
    expect(last_cycle).to have_content '394'
  end

  def description(provider_name)
    "This table shows the number of deferred offers from #{provider_name} so far this recruitment cycle, compared to national data."
  end
end
