require 'rails_helper'

RSpec.describe ProviderInterface::RecruitmentPerformanceReport::CandidatesRejectedTableComponent do
  it 'renders the report with expected columns and formats', :aggregate_failures do
    provider_report = create(:provider_recruitment_performance_report)
    provider = provider_report.provider
    national_statistics = create(:national_recruitment_performance_report).statistics

    render_inline described_class.new(provider, provider_report.statistics, national_statistics)

    expect(page).to have_table('7. Candidates rejected')
    expect(page).to have_content(description(provider.name))

    expect(page).to have_content provider.name
    expect(page).to have_content 'All providers'
    expect(page).to have_content 'Subject'
    ['This cycle', 'Last cycle', 'Percentage change'].each do |heading|
      expect(page).to have_element('th', scope: 'col', class: 'govuk-table__header', text: heading).twice
    end

    primary_row = page.find('tr.govuk-table__row', text: 'Primary')
    expect(primary_row).to have_content '2'
    expect(primary_row).to have_content '40'
    expect(primary_row).to have_content '-95%'
    expect(primary_row).to have_content '2,446'
    expect(primary_row).to have_content '2,951'
    expect(primary_row).to have_content '-17%'

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
     'Chemistry',
     'Computing',
     'Design & Technology',
     'Drama',
     'English',
     'Geography',
     'History',
     'Mathematics',
     'Modern Foreign Languages',
     'Music',
     'Others',
     'Physical Education',
     'Physics',
     'Religious Education']
  end

  def description(provider_name)
    "This table shows the number of candidates who have had all their applications to #{provider_name} rejected so far this recruitment cycle."
  end
end
