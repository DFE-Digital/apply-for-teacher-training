require 'rails_helper'

RSpec.describe GetCoursesRatifiedByProvider do
  let(:provider) { create(:provider) }

  it 'returns courses in the current year' do
    course_current_year = create(:course, :open_on_apply, accredited_provider: provider)
    create_list(:course_option, 3, course: course_current_year)

    create(:course_option, course: create(:course, :open_on_apply, :previous_year, accredited_provider: provider))

    result = described_class.call(provider: provider)
    expect(result).to contain_exactly(course_current_year)
  end

  it 'only returns courses with a course option' do
    create(:course, :open_on_apply, accredited_provider: provider)

    result = described_class.call(provider: provider)
    expect(result).to be_empty
  end

  it 'excludes courses a provider runs' do
    create(:course, :open_on_apply, provider: provider, accredited_provider: provider)
    create(:course, :open_on_apply, provider: provider)

    result = described_class.call(provider: provider)
    expect(result).to be_empty
  end

  it 'only returns courses that are open on apply' do
    create(:course, accredited_provider: provider)

    result = described_class.call(provider: provider)
    expect(result).to be_empty
  end
end
