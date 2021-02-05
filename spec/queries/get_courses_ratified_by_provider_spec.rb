require 'rails_helper'

RSpec.describe GetCoursesRatifiedByProvider do
  let!(:provider) { create(:provider) }
  let!(:course_current_year) { create(:course, accredited_provider: provider) }
  let!(:course_previous_year) { create(:course, :previous_year, accredited_provider: provider) }
  let!(:course_run_by_provider) { create(:course, provider: provider, accredited_provider: provider) }
  let!(:course_unrelated) { create(:course) }

  it 'uses the current recruitment cycle year by default' do
    result = described_class.call(provider: provider)
    expect(result).to match_array([course_current_year])
  end

  it 'can return courses for a different year if required' do
    result = described_class.call(provider: provider, recruitment_cycle_year: RecruitmentCycle.previous_year)
    expect(result).to match_array([course_previous_year])
  end

  it 'excludes courses a provider runs' do
    result = described_class.call(provider: provider)
    expect(result).not_to include(course_run_by_provider)
  end
end
