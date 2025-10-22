require 'rails_helper'

RSpec.describe ProviderInterface::ReadOnlyCompletedOfferSummaryComponent do
  include Rails.application.routes.url_helpers

  let(:application_choice) do
    build_stubbed(:application_choice,
                  :offered,
                  offer: build(:offer, conditions:))
  end
  let(:conditions) { [build(:text_condition, description: 'condition 1')] }
  let(:course_option) { build_stubbed(:course_option) }
  let(:providers) { [] }
  let(:course) { build_stubbed(:course) }
  let(:courses) { [] }
  let(:course_options) { [] }
  let(:editable) { false }
  let(:render) do
    render_inline(described_class.new(application_choice:,
                                      course_option:,
                                      conditions:,
                                      available_providers: providers,
                                      available_courses: courses,
                                      available_course_options: course_options,
                                      course:,
                                      editable: false))
  end

  def row_text_selector(row_name, render)
    rows = if course.accredited_provider.nil?
             {
               provider: 0,
               course: 1,
               full_or_part_time: 2,
               location: 3,
               qualification: 4,
               funding_type: 5,
             }
           else
             {
               provider: 0,
               course: 1,
               full_or_part_time: 2,
               location: 3,
               accredited_provider: 4,
               qualification: 5,
               funding_type: 6,
             }
           end

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  it 'renders the new course option details' do
    expect(row_text_selector(:provider, render)).to include(course_option.provider.name)
    expect(row_text_selector(:course, render)).to include(course_option.course.name_and_code)
    expect(row_text_selector(:location, render)).to include(course_option.site.name_and_address("\n"))
    expect(row_text_selector(:full_or_part_time, render)).to include(course_option.study_mode.humanize)
    expect(row_text_selector(:qualification, render)).to include('QTS with PGCE')
    expect(row_text_selector(:funding_type, render)).to include(course_option.course.funding_type.humanize)
  end

  context 'when the accredited provider is not the same as the training provider' do
    let(:course) { build_stubbed(:course, :with_accredited_provider) }
    let(:course_option) { build_stubbed(:course_option, course:) }

    it 'renders an extra row with the accredited provider details' do
      expect(row_text_selector(:accredited_provider, render)).to include(course.accredited_provider.name_and_code)
    end
  end
end
