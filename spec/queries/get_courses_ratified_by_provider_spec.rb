require 'rails_helper'

RSpec.describe GetCoursesRatifiedByProvider do
  let(:provider) { create(:provider) }
  let(:previous_cycle) { false }

  it 'returns courses in the current year' do
    course_current_year = create(:course, accredited_provider: provider)
    create_list(:course_option, 3, course: course_current_year)

    create(:course_option, course: create(:course, :previous_year, accredited_provider: provider))

    result = described_class.call(provider:, previous_cycle:)
    expect(result).to contain_exactly(course_current_year)
  end

  it 'only returns courses with a course option' do
    create(:course, accredited_provider: provider)

    result = described_class.call(provider:, previous_cycle:)
    expect(result).to be_empty
  end

  it 'excludes courses a provider runs' do
    create(:course, provider:, accredited_provider: provider)
    create(:course, provider:)

    result = described_class.call(provider:, previous_cycle:)
    expect(result).to be_empty
  end

  it 'returns courses in the previous year' do
    previous_cycle = true
    course_previous_year = create(:course, :previous_year, accredited_provider: provider)
    create_list(:course_option, 3, course: course_previous_year)

    create(:course_option, course: create(:course, accredited_provider: provider))

    result = described_class.call(provider:, previous_cycle:)
    expect(result).to contain_exactly(course_previous_year)
  end
end
