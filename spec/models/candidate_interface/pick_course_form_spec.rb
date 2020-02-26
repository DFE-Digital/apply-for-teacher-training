require 'rails_helper'

RSpec.describe CandidateInterface::PickCourseForm do
  describe '#available_courses' do
    it 'returns courses that candidates can choose from' do
      provider = create(:provider, name: 'School with courses')
      create(:course, exposed_in_find: false, open_on_apply: true, name: 'Course not shown in Find', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: false, name: 'Course not open on apply', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course you can apply to', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course from other provider')

      form = described_class.new(provider_id: provider.id)

      expect(form.available_courses.map(&:name)).to eql(['Course not open on apply', 'Course you can apply to'])
    end
  end

  describe '#single_site?' do
    let(:provider) { create(:provider, name: 'Royal Academy of Dance', code: 'R55') }
    let(:course) { create(:course, provider: provider, exposed_in_find: true, open_on_apply: true) }
    let(:site) { create(:site, provider: provider) }
    let(:pick_course_form) { described_class.new(provider_id: provider.id, course_id: course.id) }

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

  describe '#both_study_modes_available?' do
    let(:provider) { create(:provider) }
    let(:full_time_course) { create(:course, provider: provider) }
    let(:part_time_course) {
      create(:course, provider: provider, study_mode: :part_time)
    }
    let(:full_time_or_part_time_course) {
      create(:course, provider: provider, study_mode: :full_time_or_part_time)
    }

    let(:form) { described_class.new(provider_id: provider.id) }

    it 'returns false for a full time course' do
      form.course_id = full_time_course.id
      expect(form.both_study_modes_available?).to be false
    end

    it 'returns false for a part time course' do
      form.course_id = part_time_course.id
      expect(form.both_study_modes_available?).to be false
    end

    it 'returns true if both study modes are available' do
      form.course_id = full_time_or_part_time_course.id

      expect(form.both_study_modes_available?).to be true
    end
  end
end
