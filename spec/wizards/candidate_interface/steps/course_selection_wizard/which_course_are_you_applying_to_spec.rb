require 'rails_helper'

RSpec.describe CandidateInterface::Steps::CourseSelectionWizard::WhichCourseAreYouApplyingTo, type: :model do
  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:state_store) { CandidateInterface::StateStores::CourseSelectionWizardStore.new(repository:) }
  let(:wizard) do
    CandidateInterface::CourseSelectionWizard.new(
      current_step:,
      current_step_params:,
      state_store:,
    ).tap do |wizard|
      wizard.current_application = current_application
    end
  end
  let(:current_application) { create(:completed_application_form) }
  let(:current_step) { :which_course_are_you_applying_for }
  let(:current_step_params) { {} }
  let(:course) { create(:course, :open) }
  let(:provider) { course.provider }

  before do
    state_store.write(provider_id: provider.id)
  end

  describe '#delegations' do
    subject(:step) { described_class.new(wizard:) }

    it { is_expected.to delegate_method(:provider).to(:wizard) }
    it { is_expected.to delegate_method(:provider_id).to(:wizard) }
  end

  describe 'validations' do
    before { create(:course_option, course:) }

    it { is_expected.to validate_presence_of(:course_id) }

    it 'is invalid if raw data is blank' do
      step = described_class.new(
        wizard:,
        course_id: course.id.to_s,
        course_id_raw: '',
      )
      expect(step.valid?).to be false
    end

    it 'is invalid if raw data does not match course name' do
      step = described_class.new(
        wizard:,
        course_id: course.id.to_s,
        course_id_raw: 'Some random thing',
      )
      expect(step.valid?).to be false
    end

    it 'is valid if id matches course name' do
      step = described_class.new(
        wizard:,
        course_id: course.id.to_s,
        course_id_raw: course.name_and_code,
      )
      expect(step.valid?).to be true
    end
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:course_id, :course_id_raw)
    end
  end

  describe '.radio_available_courses' do
    let(:step) { described_class.new(wizard:) }

    before do
      pick_course_form = Struct.new(:radio_available_courses)
      allow(step).to receive(:pick_course_form).and_return(pick_course_form.new(radio_available_courses: 'Radio available courses'))
    end

    it 'calls the CandidateInterface::PickCourseForm radio_available_courses method' do
      expect(step.radio_available_courses).to eq('Radio available courses')
    end
  end

  describe '.dropdown_available_courses' do
    let(:step) { described_class.new(wizard:) }

    before do
      pick_course_form = Struct.new(:dropdown_available_courses)
      allow(step).to receive(:pick_course_form).and_return(pick_course_form.new(dropdown_available_courses: 'Dropdown available courses'))
    end

    it 'calls the CandidateInterface::PickCourseForm dropdown_available_courses method' do
      expect(step.dropdown_available_courses).to eq('Dropdown available courses')
    end
  end

  describe 'select_course_options' do
    let(:step) { described_class.new(wizard:) }
    let(:closed_course) { create(:course, :closed, provider:) }
    let(:unavailable_course) { create(:course, :unavailable, provider:) }
    let(:no_vacancies_course) { create(:course, :with_no_vacancies, provider:) }

    before do
      state_store.write(provider_id: provider.id)

      create(:course_option, course:)
      create(:course_option, course: closed_course)
      create(:course_option, course: unavailable_course)
      no_vacancies_course
    end

    it 'returns the courses options as an array' do
      expect(step.select_course_options).to contain_exactly(
        [nil, nil],
        [course.name_and_code, course.id],
      )
    end
  end

  describe '.completed?' do
    context 'when the course has multiple study modes' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: true, multiple_sites?: false, duplicate_course?: false, reapplication_limit_reached?: false, course_unavailable?: false, course_closed?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:).completed?).to be(false)
      end
    end

    context 'when the course has multiple sites' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: true, duplicate_course?: false, reapplication_limit_reached?: false, course_unavailable?: false, course_closed?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:).completed?).to be(false)
      end
    end

    context 'when the course has a duplicate course' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, duplicate_course?: true, reapplication_limit_reached?: false, course_unavailable?: false, course_closed?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:).completed?).to be(false)
      end
    end

    context 'when the candidate has reached their reapplication limit' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, duplicate_course?: false, reapplication_limit_reached?: true, course_unavailable?: false, course_closed?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:).completed?).to be(false)
      end
    end

    context 'when the course is unavailable' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, duplicate_course?: false, reapplication_limit_reached?: false, course_unavailable?: true, course_closed?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:).completed?).to be(false)
      end
    end

    context 'when the course is closed' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, duplicate_course?: false, reapplication_limit_reached?: false, course_unavailable?: false, course_closed?: true)
      end

      it 'returns false' do
        expect(described_class.new(wizard:).completed?).to be(false)
      end
    end

    context 'when the course is open, available and has only one study mode and site' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: false, duplicate_course?: false, reapplication_limit_reached?: false, course_unavailable?: false, course_closed?: false)
      end

      it 'returns true' do
        expect(described_class.new(wizard:).completed?).to be(true)
      end
    end
  end
end
