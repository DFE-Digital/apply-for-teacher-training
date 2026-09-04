require 'rails_helper'

RSpec.describe CandidateInterface::Steps::CourseSelectionWizard::VisaExplanation, type: :model do
  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(visa_explanation: nil, visa_explanation_details: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:visa_explanation) }

    context 'when visa_explanation is "other"' do
      it 'visa_explanation_details' do
        step = described_class.new(wizard: nil, visa_explanation: 'other')
        expect(step.valid?).to be(false)
        expect(step.errors).to contain_exactly('Visa explanation details Enter details explaining your visa situation')
      end
    end
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:visa_explanation, :visa_explanation_details)
    end
  end
end
