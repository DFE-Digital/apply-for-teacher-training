require 'rails_helper'

RSpec.describe CandidateInterface::GroupedProviderCoursesComponent do
  let(:course) { create(:course) }

  before do
    allow(GetOpenCoursesByProviderAndRegion).to receive(:call).and_return(
      {
        'north_west' => [
          GetOpenCoursesByProviderAndRegion::RegionProviderCourses.new('north_west', course.provider.name, [course]),
          GetOpenCoursesByProviderAndRegion::RegionProviderCourses.new('north_west', 'Westerly Sixth Form', []),
        ],
        'south_east' => [
          GetOpenCoursesByProviderAndRegion::RegionProviderCourses.new('south_east', 'Southerly College', []),
          GetOpenCoursesByProviderAndRegion::RegionProviderCourses.new('south_east', 'Easterly Sixth Form', []),
        ],
        nil => [
          GetOpenCoursesByProviderAndRegion::RegionProviderCourses.new(nil, 'Wimbley College', []),
          GetOpenCoursesByProviderAndRegion::RegionProviderCourses.new(nil, 'Worbley Sixth Form', []),
        ],
      },
    )
  end

  it 'renders all the region headings' do
    Timecop.travel(CycleTimetable.find_opens + 1.hour) do
      result = render_inline(described_class.new)

      expect(result.css('h2').text).to include('South East')
      expect(result.css('h2').text).to include('North West')
      expect(result.css('h2').text).to include('No region')
      expect(result.css('a').to_html).to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{course.provider.code}/#{course.code}")
    end
  end

  context 'when find is down' do
    it 'does not include a link to find' do
      Timecop.travel(CycleTimetable.find_closes.end_of_day + 1.hour) do
        result = render_inline(described_class.new)
        expect(result.css('a').to_html).not_to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{course.provider.code}/#{course.code}")
      end
    end
  end
end
