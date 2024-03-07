require 'rails_helper'

RSpec.describe Course do
  subject(:course) { build(:course) }

  describe 'a valid course' do
    it { is_expected.to validate_presence_of :level }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(%i[recruitment_cycle_year provider_id]) }
    it { is_expected.to be_application_status_closed }
  end

  describe '#open?' do
    context 'when all conditions are satisfied' do
      let(:course) { create(:course, :open) }

      it 'returns true' do
        expect(course).to be_open
      end
    end

    context 'when applications_open_from is nil' do
      let(:course) { create(:course, applications_open_from: nil) }

      it 'returns false' do
        expect(course.open?).to be false
      end
    end

    context 'when applications_open_from is in the future' do
      let(:course) { create(:course, :open, applications_open_from: 1.day.from_now) }

      it 'returns false' do
        expect(course).not_to be_open
      end
    end

    context 'when application_status is closed' do
      let(:course) { create(:course, :open, application_status: 'closed') }

      it 'returns false' do
        expect(course).not_to be_open
      end
    end

    context 'when exposed_in_find is false' do
      let(:course) { create(:course, :open, exposed_in_find: false) }

      it 'returns false' do
        expect(course).not_to be_open
      end
    end
  end

  describe '.open' do
    context 'when course is open' do
      let(:course) { create(:course, :open) }

      it 'returns open course' do
        expect(described_class.open).to include(course)
      end
    end

    context 'when not exposed_in_find' do
      let(:course) { create(:course, :open, exposed_in_find: false) }

      it 'does not return the course' do
        expect(described_class.open).not_to include(course)
      end
    end

    context 'when course is due to open tomorrow' do
      let(:course) { create(:course, :open, applications_open_from: 1.day.from_now) }

      it 'does not return the course' do
        expect(described_class.open).not_to include(course)
      end
    end

    context 'when course is closed by provider' do
      let(:course) { create(:course, :open, application_status: 'closed') }

      it 'does not return the course' do
        expect(described_class.open).not_to include(course)
      end
    end
  end

  describe '#currently_has_both_study_modes_available?' do
    it 'is true when a course has full time and part time course options' do
      create(:course_option, :full_time, course:)
      create(:course_option, :part_time, course:)

      expect(course.currently_has_both_study_modes_available?).to be true
    end

    it 'is false when a course only has availability on one study mode' do
      create(:course_option, :full_time, course:)
      create(:course_option, :part_time, :no_vacancies, course:)

      expect(course.currently_has_both_study_modes_available?).to be false
    end
  end

  describe '#available_study_modes_with_vacancies' do
    it 'returns an array of unique study modes for course options with available vacancies' do
      create_list(:course_option, 2, :no_vacancies, :full_time, course:)
      create(:course_option, :part_time, course:)

      expect(course.available_study_modes_with_vacancies).to eq %w[part_time]
    end
  end

  describe '#full?' do
    subject(:course) { create(:course) }

    context 'when there are no course options' do
      it 'returns true' do
        expect(course.full?).to be true
      end
    end

    context 'when a subset of course options have vacancies' do
      before do
        create(:course_option, course:, vacancy_status: 'vacancies')
        create(:course_option, course:, vacancy_status: 'no_vacancies')
      end

      it 'returns false' do
        expect(course.full?).to be false
      end
    end

    context 'when no course options have vacancies' do
      before do
        create(:course_option, course:, vacancy_status: 'no_vacancies')
        create(:course_option, course:, vacancy_status: 'no_vacancies')
      end

      it 'returns false' do
        expect(course.full?).to be true
      end
    end
  end

  describe '#in_previous_cycle' do
    it 'returns nil when there is no equivalent in the previous cycle' do
      course = create(:course)

      expect(course.in_previous_cycle).to be_nil
    end

    it 'returns the equivalent in the previous cycle when there is one' do
      provider = create(:provider)
      course_in_previous_cycle = create(:course, code: 'ABC', provider:, recruitment_cycle_year: 2019)

      course = create(:course, code: 'ABC', provider:, recruitment_cycle_year: 2020)

      expect(course.in_previous_cycle).to eq course_in_previous_cycle
    end
  end

  describe '#subject_codes' do
    let(:course) { create(:course, subjects: [create(:subject, code: '01'), create(:subject, code: '9X')]) }

    it 'returns an array with all the codes of the course subjects' do
      expect(course.subject_codes).to contain_exactly('01', '9X')
    end
  end

  describe '#ratifying_provider' do
    context 'when there is an accredited provider set' do
      let(:course) { build(:course, accredited_provider: build(:provider)) }

      it 'returns the accredited provider' do
        expect(course.ratifying_provider).to eq(course.accredited_provider)
      end
    end

    context 'when there is no accredited provider set' do
      let(:course) { build(:course) }

      it 'returns the provider' do
        expect(course.ratifying_provider).to eq(course.provider)
      end
    end
  end

  describe '#open!' do
    it 'sets both open_on_apply and opened_on_apply_at' do
      course = create(:course)
      course.open!
      expect(course.open_on_apply).to be(true)
      expect(course.opened_on_apply_at).to eq(Time.zone.now)
    end

    it 'does not update the timestamp if course already open' do
      course = create(:course, :open_on_apply)
      expect { course.open! }.not_to change(course, :opened_on_apply_at)
    end
  end

  describe '#find_url' do
    let(:course) { create(:course) }

    it 'returns the sandbox url when in sandbox', :sandbox do
      expect(course.find_url).to match(/sandbox/)
    end

    it 'returns the production url when not in sandbox', sandbox: false do
      expect(course.find_url).not_to match(/sandbox/)
    end
  end

  describe '#description_and_accredited_provider' do
    context 'when there is an accredited provider set' do
      let(:course) { build(:course, accredited_provider: build(:provider)) }

      it 'returns the accredited provider' do
        result_string = "#{course.description} - #{course.accredited_provider.name}"

        expect(course.description_and_accredited_provider).to eq(result_string)
      end
    end

    context 'when there is no accredited provider set' do
      let(:course) { build(:course) }

      it 'returns the provider' do
        expect(course.description_and_accredited_provider).to eq(course.description)
      end
    end
  end

  describe 'qualificaitons_to_s' do
    subject { course.qualifications_to_s }

    let(:course) { build(:course, qualifications:) }

    context 'when nil' do
      let(:qualifications) { nil }

      it { is_expected.to eq('') }
    end

    context 'when [qts pgce]' do
      let(:qualifications) { %w[qts pgce] }

      it { is_expected.to eq('PGCE with QTS') }
    end

    context 'when [qts pgde]' do
      let(:qualifications) { %w[qts pgde] }

      it { is_expected.to eq('PGDE with QTS') }
    end

    context 'when [qts]' do
      let(:qualifications) { %w[qts] }

      it { is_expected.to eq('QTS') }
    end

    context 'when [pgce]' do
      let(:qualifications) { %w[pgce] }

      it { is_expected.to eq('PGCE') }
    end
  end

  describe '#ske_graduation_cutoff_date' do
    let(:course) { build(:course, start_date: Date.new(2023, 1, 1)) }

    it 'returns correct date' do
      expect(course.ske_graduation_cutoff_date).to eq(Date.new(2018, 1, 1))
    end
  end
end
