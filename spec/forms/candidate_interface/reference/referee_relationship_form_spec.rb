require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RefereeRelationshipForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:relationship) }
  end

  describe '.build_from_reference' do
    it 'creates an object based on the reference' do
      application_reference = build_stubbed(:reference, relationship: 'No comment.')
      form = described_class.build_from_reference(application_reference)

      expect(form.relationship).to eq('No comment.')
    end
  end

  describe '#save' do
    let(:application_reference) { create(:reference) }

    before do
      FeatureFlag.activate('decoupled_references')
    end

    context 'when relationship is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_reference)).to be(false)
      end
    end

    context 'when relationship has a value' do
      it 'creates the referee' do
        form = described_class.new(relationship: 'No comment.')
        form.save(application_reference)

        expect(application_reference.relationship).to eq('No comment.')
      end
    end
  end
end
