require 'rails_helper'

RSpec.describe CandidateInterface::PickCourseForm do
  describe '#radio_available_courses' do
    it 'returns courses that candidates can choose from' do
      provider = create(:provider, name: 'School with courses')
      create(:course, exposed_in_find: false, open_on_apply: true, name: 'Course not shown in Find', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: false, name: 'Course not open on apply', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course you can apply to', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course from other provider')

      form = described_class.new(provider_id: provider.id)

      expect(form.radio_available_courses.map(&:name)).to eql(['Course not open on apply', 'Course you can apply to'])
    end
  end

  describe '#dropdown_available_courses' do
    context 'with no ambiguous courses' do
      it 'returns each courses name and code' do
        provider = create(:provider)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: '789', description: 'PGCE with QTS full time', provider: provider)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['English (789)', 'Maths (123)'])
      end
    end

    context 'when courses have ambiguous names and different descriptions' do
      it 'adds the course description to the name of the course' do
        provider = create(:provider)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: '789', description: 'PGCE with QTS full time', provider: provider)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['English (789)', 'Maths (123) – PGCE full time', 'Maths (456) – PGCE with QTS full time'])
      end
    end

    context 'when courses have ambiguous names and the same description' do
      it 'adds the accrediting provider name to the the name of the course' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE with QTS full time', provider: provider, accrediting_provider: provider2)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider, accrediting_provider: provider3)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['Maths (123) – BIG SCITT', 'Maths (456) – EVEN BIGGER SCITT'])
      end
    end

    context 'when courses have the same accrediting provider and different descriptions' do
      it 'prioritises showing the description over the accrediting provider name' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider, accrediting_provider: provider2)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider, accrediting_provider: provider3)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['Maths (123) – PGCE full time', 'Maths (456) – PGCE with QTS full time'])
      end
    end

    context 'with multiple ambigious names' do
      it 'returns the correct values' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider, accrediting_provider: provider2)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider, accrediting_provider: provider2)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '789', description: 'PGCE with QTS full time', provider: provider, accrediting_provider: provider3)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: 'A01', description: 'PGCE full time', provider: provider, accrediting_provider: provider3)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: 'A02', description: 'PGCE with QTS full time', provider: provider, accrediting_provider: provider2)
        create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: 'A03', description: 'PGCE with QTS full time', provider: provider, accrediting_provider: provider3)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(
          ['English (A01) – PGCE full time',
           'English (A02) – BIG SCITT',
           'English (A03) – EVEN BIGGER SCITT',
           'Maths (123) – PGCE full time',
           'Maths (456) – BIG SCITT',
           'Maths (789) – EVEN BIGGER SCITT'],
         )
      end
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
