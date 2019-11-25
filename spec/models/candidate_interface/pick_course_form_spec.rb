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
end
