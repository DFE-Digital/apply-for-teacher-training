require 'rails_helper'

RSpec.describe CandidateInterface::Steps::CourseSelectionWizard::ProviderSelection, type: :model do
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
  let(:current_step) { :course_study_mode }
  let(:current_step_params) { {} }
  let(:provider) { create(:provider) }
  let(:course) { create(:course, :open, provider: provider) }

  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(provider_id: nil, provider_id_raw: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider_id) }

    context 'validates that the provider id matches the provider id raw data' do
      before { course }

      it 'is invalid if raw data is blank' do
        step = described_class.new(
          wizard:,
          provider_id: provider.id.to_s,
          provider_id_raw: '',
        )
        expect(step.valid?).to be false
      end

      it 'is invalid if raw data does not match provider name and code' do
        step = described_class.new(
          wizard:,
          provider_id: provider.id.to_s,
          provider_id_raw: 'Some random thing',
        )
        expect(step.valid?).to be false
      end

      it 'is valid if id matches provider name and code' do
        step = described_class.new(
          wizard:,
          provider_id: provider.id.to_s,
          provider_id_raw: "#{provider.name} (#{provider.code})",
        )
        expect(step.valid?).to be true
      end
    end
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:provider_id, :provider_id_raw)
    end
  end

  describe '.select_provider_options' do
    let(:provider_1) { create(:provider) }
    let(:provider_2) { create(:provider) }
    let(:course_1) { create(:course, :open, provider: provider_1) }
    let(:course_2) { create(:course, :open, provider: provider_2) }
    let(:invalid_provider) { create(:provider) }
    let(:unavailable_provider) { create(:provider) }
    let(:closed_course) { create(:course, :closed, provider: unavailable_provider) }

    before do
      invalid_provider
      course_1
      course_2
      closed_course
    end

    it 'returns all available providers as an array' do
      expect(described_class.new(wizard:).select_provider_options).to contain_exactly(
        [nil, nil],
        [provider_1.name_and_code, provider_1.id],
        [provider_2.name_and_code, provider_2.id],
      )
    end
  end
end
