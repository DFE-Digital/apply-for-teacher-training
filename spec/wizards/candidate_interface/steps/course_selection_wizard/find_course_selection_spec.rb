require 'rails_helper'

RSpec.describe CandidateInterface::Steps::CourseSelectionWizard::FindCourseSelection, type: :model do
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
  let(:current_step) { :find_course_selection }
  let(:current_step_params) { {} }
  let(:course) { create(:course, :open) }

  describe '#delegations' do
    subject(:step) { described_class.new(wizard:, course_id: course.id) }

    it { is_expected.to delegate_method(:multiple_study_modes?).to(:wizard) }
    it { is_expected.to delegate_method(:multiple_sites?).to(:wizard) }

    it { is_expected.to delegate_method(:find_url).to(:course).with_prefix }
    it { is_expected.to delegate_method(:provider).to(:course).with_prefix }
    it { is_expected.to delegate_method(:name_and_code).to(:course).with_prefix }
  end

  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(course_id: nil, confirm: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_id) }
    it { is_expected.to validate_presence_of(:confirm) }
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:course_id, :confirm)
    end
  end

  describe '.course' do
    let(:course) { create(:course, :open) }
    let(:step) { described_class.new(wizard:, course_id: course.id) }

    it 'returns the course associated with the course id' do
      expect(step.course).to eq(course)
    end
  end

  describe '.completed?' do
    context 'when the course has multiple sites' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: true)
      end

      it 'returns false' do
        expect(described_class.new(wizard:, course_id: course.id, confirm: 'true').completed?).to be(false)
      end
    end

    context 'when the course has multiple study modes' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: true, multiple_sites?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:, course_id: course.id, confirm: 'true').completed?).to be(false)
      end
    end

    context 'when not confirmed' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:, course_id: course.id, confirm: 'false').completed?).to be(false)
      end
    end

    context 'when confirmed' do
      before do
        allow(wizard).to receive_messages(multiple_study_modes?: false, multiple_sites?: false)
      end

      it 'returns false' do
        expect(described_class.new(wizard:, course_id: course.id, confirm: 'true').completed?).to be(true)
      end
    end
  end

  describe '.confirm_answer?' do
    context 'when confirm is "false"' do
      it 'returns false' do
        expect(described_class.new(wizard:, course_id: course.id, confirm: 'false').confirm_answer?).to be(false)
      end
    end

    context 'when confirm is "true"' do
      it 'returns true' do
        expect(described_class.new(wizard:, course_id: course.id, confirm: 'true').confirm_answer?).to be(true)
      end
    end
  end
end
