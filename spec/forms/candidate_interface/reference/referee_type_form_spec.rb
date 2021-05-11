require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RefereeTypeForm, type: :model do
  describe '.build_from_reference' do
    it 'creates an object based on the reference' do
      application_reference = build_stubbed(:reference, referee_type: :school_based)
      form = described_class.build_from_reference(application_reference)

      expect(form.referee_type).to eq('school_based')
    end
  end

  describe '#update' do
    let(:application_reference) { create(:reference) }

    context 'when referee_type is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.update(application_reference)).to be(false)
      end
    end

    context 'when referee_type has a value' do
      it 'updates the reference' do
        form = described_class.new(referee_type: 'professional')
        form.update(application_reference)

        expect(application_reference.referee_type).to eq('professional')
      end

      it 'updates the existing referee_type of the reference' do
        application_reference = create(:reference, referee_type: 'school-based')
        form = described_class.new(referee_type: 'professional')
        form.update(application_reference)

        expect(application_reference.referee_type).to eq('professional')
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:referee_type) }
  end
end
