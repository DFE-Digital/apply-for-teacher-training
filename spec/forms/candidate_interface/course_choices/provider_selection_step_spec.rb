require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::ProviderSelectionStep do
  subject(:provider_selection_step) { described_class.new(provider_id: provider_id) }

  let(:provider_id) { 123 }

  describe '.route_name' do
    subject { provider_selection_step.class.route_name }

    it { is_expected.to eq('candidate_interface_course_choices_provider_selection') }
  end

  it 'returns the correct next step' do
    expect(provider_selection_step.next_step).to eq(:which_course_are_you_applying_to)
  end

  describe 'validates' do
    it { is_expected.to validate_presence_of(:provider_id) }

    context 'validates that the provider id matches the provider id raw data' do
      let(:provider) { create(:provider) }
      let!(:course) { create(:course, :open, provider:) }

      it 'is invalid if raw data is blank' do
        subject = described_class.new(provider_id: provider.id.to_s, provider_id_raw: '')
        expect(subject.valid?).to be false
      end

      it 'is invalid if raw data does not match provider name and code' do
        subject = described_class.new(provider_id: provider.id.to_s, provider_id_raw: 'Some random thing')
        expect(subject.valid?).to be false
      end

      it 'is valid if id matches provider name and code' do
        subject = described_class.new(provider_id: provider.id.to_s, provider_id_raw: "#{provider.name} (#{provider.code})")
        expect(subject.valid?).to be true
      end
    end
  end
end
