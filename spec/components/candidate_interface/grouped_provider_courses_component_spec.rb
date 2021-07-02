require 'rails_helper'

RSpec.describe CandidateInterface::GroupedProviderCoursesComponent do
  let(:course) { create(:course) }

  before do
    @courses_by_provider_and_region = {
      'north_west' => [
        CandidateInterface::ContentController::RegionProviderCourses.new('north_west', course.provider.name, [course]),
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
    expect(result.css('a').to_html).to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{course.provider.code}/#{course.code}")
  end

  context 'when find is down' do
    it 'does not include a link to find' do
      Timecop.travel(CycleTimetable.find_closes.end_of_day + 1.hour) do
        result = render_inline(
          described_class.new(courses_by_provider_and_region: @courses_by_provider_and_region),
        )
        expect(result.css('a').to_html).not_to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{course.provider.code}/#{course.code}")
      end
    end
  end
end
