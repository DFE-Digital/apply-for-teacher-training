require 'rails_helper'

RSpec.describe CandidateInterface::PickCourseForm do
  describe '#available_courses' do
    it 'returns courses that candidates can apply to' do
      provider = create(:provider, name: 'School with courses')
      create(:course, exposed_in_find: false, open_on_apply: true, name: 'Course not shown in Find', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: false, name: 'Course not open on apply', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course you can apply to', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course from other provider')

      form = CandidateInterface::PickCourseForm.new(provider_code: provider.code)

      expect(form.available_courses.map(&:name)).to eql(['Course you can apply to'])
    end
  end

  describe '#single_site?' do
    let(:provider) { create(:provider, name: 'Royal Academy of Dance', code: 'R55') }
    let(:course) { create(:course, provider: provider, exposed_in_find: true, open_on_apply: true) }
    let(:site) { create(:site, provider: provider) }
    let(:pick_course_form) { CandidateInterface::PickCourseForm.new(provider_code: provider.code, code: course.code) }

    before { create(:course_option, site: site, course: course) }

    it 'returns true when there is one site for a course' do
      expect(pick_course_form).to be_single_site
    end

    it 'returns false when there are more than one site for a course' do
      another_site = create(:site, provider: provider)
      create(:course_option, site: another_site, course: course)

      expect(pick_course_form).not_to be_single_site
    end
  end
end
