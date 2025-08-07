require 'rails_helper'

RSpec.describe CandidateInterface::PickCourseForm do
  describe '#radio_available_courses' do
    it 'returns courses that candidates can choose from' do
      provider = create(:provider, name: 'School with courses')

      create(:course, :open, exposed_in_find: false, name: 'Course not shown in Find', provider:)
      create(:course, exposed_in_find: true, name: 'Course that is not accepting applications', provider:, code: 'BBBB')
      create(:course, :open, name: 'Course you can apply to', provider:, code: 'CCCC')
      create(:course, :open, name: 'Course from another cycle', provider:, recruitment_cycle_year: 2021)
      create(:course, :open, name: 'Course from other provider')
      create(:course, :open, :with_course_options, name: 'Course with availability', provider:, code: 'DDDD', description: 'Custom description')

      form = described_class.new(provider_id: provider.id)

      expect(form.radio_available_courses.map(&:label)).to contain_exactly(
        'Course that is not accepting applications (BBBB) – No vacancies',
        'Course with availability (DDDD)',
        'Course you can apply to (CCCC) – No vacancies',
      )

      expect(form.radio_available_courses.map(&:hint)).to contain_exactly(
        'QTS with PGCE full time',
        'Custom description',
        'QTS with PGCE full time',
      )
    end
  end

  describe 'input methods' do
    before do
      course = create(
        :course,
        :open,
        name: 'Maths',
        code: '123',
        provider:,
      )
      create(
        :course,
        :open,
        name: 'English',
        code: '456',
        description: 'QTS with PGCE full time',
        provider:,
      )
      create(
        :course,
        :open,
        name: 'English',
        code: '789',
        description: 'PGCE full time',
        provider:,
      )
      create(:course_option, course:)
    end

    let(:provider) { create(:provider) }
    let(:form) { described_class.new(provider_id: provider.id) }

    describe '#radio_available_courses' do
      it 'displays the course name, code and vacancy status' do
        expect(
          form.radio_available_courses.map(&:label),
        ).to contain_exactly(
          'English (456) – No vacancies',
          'English (789) – No vacancies',
          'Maths (123)',
        )
      end

      it 'displays the course description as a hint' do
        expect(
          form.radio_available_courses.map(&:hint),
        ).to contain_exactly(
          'QTS with PGCE full time',
          'PGCE full time',
          'QTS with PGCE full time',
        )
      end
    end

    describe '#dropdown_available_courses' do
      it 'displays the course name, code and vacancy status' do
        expect(
          form.dropdown_available_courses.map(&:name),
        ).to contain_exactly(
          'English (456) – QTS with PGCE full time – No vacancies',
          'English (789) – PGCE full time – No vacancies',
          'Maths (123)',
        )
      end
    end

    it 'respects the current recruitment cycle' do
      provider = create(:provider)
      course = create(:course, :open, name: 'This cycle', code: 'A', provider:)
      create(:course, :open, name: 'A past cycle', code: 'F', provider:, recruitment_cycle_year: 2021)

      create(:course_option, course:)

      form = described_class.new(provider_id: provider.id)

      expect(form.dropdown_available_courses.map(&:name)).to eql(['This cycle (A)'])
    end

    context 'with no ambiguous courses' do
      it 'returns each courses name and code' do
        provider = create(:provider)
        maths_course = create(:course, :open, name: 'Maths', code: '123', description: 'PGCE full time', provider:)
        english_course = create(:course, :open, name: 'English', code: '789', description: 'PGCE with QTS full time', provider:)
        mathematics_undergraduate_course = create(:course, :open, :teacher_degree_apprenticeship, name: 'Mathematics', code: '790', provider:)
        create(:course_option, course: maths_course)
        create(:course_option, course: english_course)
        create(:course_option, course: mathematics_undergraduate_course)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to contain_exactly('English (789)', 'Maths (123)', 'Mathematics (790) – Teacher degree apprenticeship with QTS')
      end
    end

    context 'when courses have ambiguous names and different descriptions' do
      it 'adds the course description to the name of the course' do
        provider = create(:provider)
        maths123 = create(:course, :open, name: 'Maths', code: '123', description: 'PGCE full time', provider:)
        maths456 = create(:course, :open, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider:)
        english789 = create(:course, :open, name: 'English', code: '789', description: 'PGCE with QTS full time', provider:)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)
        create(:course_option, course: english789)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to contain_exactly(
          'English (789)',
          'Maths (123) – PGCE full time',
          'Maths (456) – QTS with PGCE full time',
        )
      end
    end

    context 'when courses have ambiguous names and the same description' do
      it 'adds the accredited provider name to the the name of the course' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        maths123 = create(:course, :open, name: 'Maths', code: '123', description: 'PGCE with QTS full time', provider:, accredited_provider: provider2)
        maths456 = create(:course, :open, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider:, accredited_provider: provider3)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to contain_exactly(
          'Maths (123) – BIG SCITT',
          'Maths (456) – EVEN BIGGER SCITT',
        )
      end
    end

    context 'when courses have the same accredited provider and different descriptions' do
      it 'prioritises showing the description over the accredited provider name' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        maths123 = create(:course, :open, name: 'Maths', code: '123', description: 'PGCE full time', provider:, accredited_provider: provider2)
        maths456 = create(:course, :open, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider:, accredited_provider: provider3)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to contain_exactly(
          'Maths (123) – PGCE full time',
          'Maths (456) – QTS with PGCE full time',
        )
      end
    end

    context 'when courses have the same accredited provider, name and description' do
      it 'returns the course name_code_and_age_range' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        maths4to8 = create(:course, :open, name: 'Maths', code: '123', description: 'QTS with PGCE full time', provider:, accredited_provider: provider2)
        maths8to12 = create(:course, :open, name: 'Maths', code: '456', age_range: '8 to 12', description: 'QTS with PGCE full time', provider:, accredited_provider: provider2)
        create(:course_option, course: maths4to8)
        create(:course_option, course: maths8to12)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to contain_exactly('Maths, 4 to 8 (123)', 'Maths, 8 to 12 (456)')
      end
    end

    context 'when courses have the same accredited provider, name, description and age range' do
      it 'returns course name and code' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        maths123 = create(:course, :open, name: 'Maths', code: '123', description: 'QTS with PGCE full time', provider:, accredited_provider: provider2)
        maths456 = create(:course, :open, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider:, accredited_provider: provider2)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to contain_exactly('Maths (123)', 'Maths (456)')
      end
    end

    context 'with multiple ambigious names' do
      it 'returns the correct values' do
        provider = create(:provider)
        provider2 = create(:provider, name: 'BIG SCITT')
        provider3 = create(:provider, name: 'EVEN BIGGER SCITT')
        maths123 = create(:course, :open, name: 'Maths', code: '123', description: 'PGCE full time', provider:, accredited_provider: provider2)
        maths456 = create(:course, :open, name: 'Maths', code: '456', description: 'PGCE with QTS full time', provider:, accredited_provider: provider2)
        maths789 = create(:course, :open, name: 'Maths', code: '789', description: 'PGCE with QTS full time', provider:, accredited_provider: provider3)
        english_a01 = create(:course, :open, name: 'English', code: 'A01', description: 'PGCE full time', provider:, accredited_provider: provider3)
        english_a02 = create(:course, :open, name: 'English', code: 'A02', description: 'PGCE with QTS full time', provider:, accredited_provider: provider2)
        english_a03 = create(:course, :open, name: 'English', code: 'A03', description: 'PGCE with QTS full time', provider:, accredited_provider: provider3)
        create(:course_option, course: maths123)
        create(:course_option, course: maths456)
        create(:course_option, course: maths789)
        create(:course_option, course: english_a01)
        create(:course_option, course: english_a02)
        create(:course_option, course: english_a03)

        form = described_class.new(provider_id: provider.id)

        expect(form.dropdown_available_courses.map(&:name)).to contain_exactly(
          'English (A01) – PGCE full time',
          'English (A02) – BIG SCITT',
          'English (A03) – EVEN BIGGER SCITT',
          'Maths (123) – PGCE full time',
          'Maths (456) – BIG SCITT',
          'Maths (789) – EVEN BIGGER SCITT',
        )
      end
    end
  end

  describe '#available_courses' do
    let(:provider) { create(:provider, name: 'Royal Academy of Dance', code: 'R55') }
    let(:course) { create(:course, :open, provider:) }
    let(:pick_course_form) { described_class.new(provider_id: provider.id, course_id: course.id) }

    context 'when there are two sites' do
      let(:site1) { build(:site, provider:) }
      let(:site2) { build(:site, provider:) }
      let(:course_option1) { create(:course_option, site: site1, course:) }
      let(:course_option2) { create(:course_option, site: site2, course:) }

      before do
        course_option1
        course_option2
      end

      it 'returns both sites' do
        expect(pick_course_form.available_course_options).to contain_exactly(course_option1, course_option2)
      end

      context 'when one site is not longer valid' do
        let(:course_option2) { create(:course_option, site: site2, course:, site_still_valid: false) }

        it 'returns only the valid site' do
          expect(pick_course_form.available_course_options).to eq([course_option1])
        end
      end
    end
  end

  describe '#single_site?' do
    let(:provider) { create(:provider, name: 'Royal Academy of Dance', code: 'R55') }
    let(:course) { create(:course, :open, provider:) }
    let(:pick_course_form) { described_class.new(provider_id: provider.id, course_id: course.id) }
    let(:site) { build(:site, provider:) }

    context 'when the is one site for a course' do
      before do
        create(:course_option, site:, course:)
      end

      it 'returns true' do
        expect(pick_course_form).to be_single_site
      end
    end

    context 'when the is one site at a course option with no available vacancies' do
      before do
        create(:course_option, :no_vacancies, site:, course:)
      end

      it 'returns false' do
        expect(pick_course_form).not_to be_single_site
      end
    end

    context 'when there are multiple sites' do
      let(:other_site) { build(:site, provider:) }

      before do
        create(:course_option, site:, course:)
        create(:course_option, site: other_site, course:)
      end

      it 'returns false' do
        expect(pick_course_form).not_to be_single_site
      end
    end
  end
end
