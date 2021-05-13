require 'rails_helper'

RSpec.describe CandidateInterface::PickCourseForm do
  describe '#radio_available_courses' do
    it 'returns courses that candidates can choose from' do
      provider = create(:provider, name: 'School with courses')

      create(:course, exposed_in_find: false, open_on_apply: true, name: 'Course not shown in Find', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: false, name: 'Course not open on apply', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course you can apply to', provider: provider)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course from another cycle', provider: provider, recruitment_cycle_year: 2016)
      create(:course, exposed_in_find: true, open_on_apply: true, name: 'Course from other provider')

      form = described_class.new(provider_id: provider.id)

      expect(form.radio_available_courses.map(&:name)).to eql(['Course not open on apply', 'Course you can apply to'])
    end
  end

  describe '#dropdown_available_courses' do
    it 'displays the vacancy status' do
      provider = create(:provider)
      course = create(:course, open_on_apply: true, exposed_in_find: true, name: 'Maths', code: '123', provider: provider)
      create(:course, open_on_apply: true, exposed_in_find: true, name: 'English', code: '456', description: 'PGCE with QTS full time', provider: provider)
      create(:course, open_on_apply: true, exposed_in_find: true, name: 'English', code: '789', description: 'PGCE full time', provider: provider)
      create(:course_option, course: course)

      form = described_class.new(provider_id: provider.id)

      expect(form.dropdown_available_courses.map(&:name)).to eql(['English (456) – PGCE with QTS full time – No vacancies', 'English (789) – PGCE full time – No vacancies', 'Maths (123)'])
    end

    it 'displays the ucas status' do
      provider = create(:provider)
      maths = create(:course, exposed_in_find: true, open_on_apply: false, name: 'Maths', code: '123', provider: provider)
      english = create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: '456', provider: provider)
      create(:course_option, course: maths)
      create(:course_option, course: english)

      form = described_class.new(provider_id: provider.id)

      expect(form.dropdown_available_courses.map(&:name)).to eql(['English (456)', 'Maths (123) – Only on UCAS'])
    end

    it 'respects the current recruitment cycle' do
      provider = create(:provider)
      course = create(:course, :open_on_apply, name: 'This cycle', code: 'A', provider: provider)
      create(:course, :open_on_apply, name: 'A past cycle', code: 'F', provider: provider, recruitment_cycle_year: 2016)

      create(:course_option, course: course)

      form = described_class.new(provider_id: provider.id)

      expect(form.dropdown_available_courses.map(&:name)).to eql(['This cycle (A)'])
    end

    context 'with no ambiguous courses' do
      it 'returns each courses name and code' do
        provider = create(:provider)
        maths_course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider)
        english_course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: '789', description: 'PGCE with QTS full time', provider: provider)
        create(:course_option, course: maths_course)
        create(:course_option, course: english_course)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['English (789)', 'Maths (123)'])
      end
    end

    context 'when courses have ambiguous names and different descriptions' do
      it 'adds the course description to the name of the course' do
        provider = create(:provider)
        maths123 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider)
        maths456 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider)
        english789 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: '789', description: 'PGCE with QTS full time', provider: provider)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)
        create(:course_option, course: english789)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['English (789)', 'Maths (123) – PGCE full time', 'Maths (456) – PGCE with QTS full time'])
      end
    end

    context 'when courses have ambiguous names and the same description' do
      it 'adds the accredited provider name to the the name of the course' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        maths123 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider2)
        maths456 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider3)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['Maths (123) – BIG SCITT', 'Maths (456) – EVEN BIGGER SCITT'])
      end
    end

    context 'when courses have the same accredited provider and different descriptions' do
      it 'prioritises showing the description over the accredited provider name' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        maths123 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider, accredited_provider: provider2)
        maths456 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider3)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['Maths (123) – PGCE full time', 'Maths (456) – PGCE with QTS full time'])
      end
    end

    context 'when courses have the same accredited provider, name and description' do
      it 'returns the course name_code_and_age_range' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        maths4to8 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider2)
        maths8to12 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', age_range: '8 to 12', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider2)
        create(:course_option, course: maths4to8)
        create(:course_option, course: maths8to12)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['Maths, 4 to 8 (123)', 'Maths, 8 to 12 (456)'])
      end
    end

    context 'when courses have the same accredited provider, name, description and age range' do
      it 'returns course name and code' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        maths123 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider2)
        maths456 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider2)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to eql(['Maths (123)', 'Maths (456)'])
      end
    end

    context 'with multiple ambigious names' do
      it 'returns the correct values' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        maths123 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '123', description: 'PGCE full time', provider: provider, accredited_provider: provider2)
        maths456 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider2)
        maths789 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Maths', code: '789', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider3)
        english_a01 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: 'A01', description: 'PGCE full time', provider: provider, accredited_provider: provider3)
        english_a02 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: 'A02', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider2)
        english_a03 = create(:course, exposed_in_find: true, open_on_apply: true, name: 'English', code: 'A03', description: 'PGCE with QTS full time', provider: provider, accredited_provider: provider3)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)
        create(:course_option, course: maths789)
        create(:course_option, course: english_a01)
        create(:course_option, course: english_a02)
        create(:course_option, course: english_a03)

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
    let(:course) { create(:course, :open_on_apply, provider: provider) }
    let(:pick_course_form) { described_class.new(provider_id: provider.id, course_id: course.id) }
    let(:site) { build(:site, provider: provider) }

    context 'when the is one site for a course' do
      before do
        create(:course_option, site: site, course: course)
      end

      it 'returns true' do
        expect(pick_course_form).to be_single_site
      end
    end

    context 'when the is one site at a course option with no available vacancies' do
      before do
        create(:course_option, :no_vacancies, site: site, course: course)
      end

      it 'returns false' do
        expect(pick_course_form).not_to be_single_site
      end
    end

    context 'when there are multiple sites' do
      let(:other_site) { build(:site, provider: provider) }

      before do
        create(:course_option, site: site, course: course)
        create(:course_option, site: other_site, course: course)
      end

      it 'returns false' do
        expect(pick_course_form).not_to be_single_site
      end
    end
  end
end
