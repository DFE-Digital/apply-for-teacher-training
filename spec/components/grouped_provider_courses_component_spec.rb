require 'rails_helper'

RSpec.describe GroupedProviderCoursesComponent do
  before do
    @courses_by_provider_and_region = {
      'north_west' => [
        CandidateInterface::ContentController::RegionProviderCourses.new('north_west', 'Northerly College', []),
        CandidateInterface::ContentController::RegionProviderCourses.new('north_west', 'Westerly Sixth Form', []),
      ],
      'south_east' => [
        CandidateInterface::ContentController::RegionProviderCourses.new('south_east', 'Southerly College', []),
        CandidateInterface::ContentController::RegionProviderCourses.new('south_east', 'Easterly Sixth Form', []),
      ],
      nil => [
        CandidateInterface::ContentController::RegionProviderCourses.new(nil, 'Wimbley College', []),
        CandidateInterface::ContentController::RegionProviderCourses.new(nil, 'Worbley Sixth Form', []),
      ],
    }
  end

  it 'renders all the region headings' do
    result = render_inline(
      described_class.new(courses_by_provider_and_region: @courses_by_provider_and_region),
    )
    expect(result.css('h2').text).to include('South East')
    expect(result.css('h2').text).to include('North West')
    expect(result.css('h2').text).to include('No region')
  end
end
