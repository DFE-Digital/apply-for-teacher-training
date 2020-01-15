require 'rails_helper'

RSpec.describe SupportInterface::ProviderCoursesTableComponent do
  describe 'course data' do
    it 'renders the correct data for a course' do
      course = create(:course,
                      name: 'My course',
                      code: 'ABC',
                      level: 'secondary',
                      recruitment_cycle_year: 2020,
                      exposed_in_find: true,
                      open_on_apply: true)

      course_option = create(:course_option, course: course)
      provider = course_option.course.provider

      render_result = render_inline(SupportInterface::ProviderCoursesTableComponent, provider: provider)

      # Make a mapping colname -> colvalue
      fields = render_result.css('th').map(&:text).zip(
        render_result.css('td').map(&:text),
      ).to_h

      expect(fields['Course']).to eq('My course (ABC)')
      expect(fields['Level']).to eq('secondary')
      expect(fields['Recruitment Cycle']).to eq('2020')
      expect(fields['Apply from Find']).to match(/DfE & UCAS/)
      expect(fields['Page on Find']).to match(/Find course page/)
    end
  end
end
