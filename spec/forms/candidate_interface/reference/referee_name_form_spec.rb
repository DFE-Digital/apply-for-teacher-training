require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RefereeNameForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '.build_from_reference' do
    it 'creates an object based on the reference' do
      application_reference = build_stubbed(:reference, name: 'Walter White')
      form = described_class.build_from_reference(application_reference)

      expect(form.name).to eq('Walter White')
    end
  end

  describe '#save' do
    let(:application_reference) { create(:reference) }

    before do
      FeatureFlag.activate('decoupled_references')
    end

    context 'when name is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_reference)).to be(false)
      end
    end

    context 'when name has a value' do
      it 'creates the referee' do
        form = described_class.new(name: 'Walter White')
        form.save(application_reference)

        expect(application_reference.name).to eq('Walter White')
      end
    end
  end
end
