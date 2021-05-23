require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RefereeNameForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2) }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }
  end

  describe '.build_from_reference' do
    it 'creates an object based on the reference' do
      application_reference = build_stubbed(:reference, name: 'Walter White')
      form = described_class.build_from_reference(application_reference)

      expect(form.name).to eq('Walter White')
    end
  end

  describe '#save' do
    let(:application_form) { create(:application_form) }

    context 'when name is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_form, 'academic')).to be(false)
      end
    end

    context 'when name and referee type have a value' do
      it 'creates the referee' do
        form = described_class.new(name: 'Walter White')
        form.save(application_form, 'academic')

        expect(application_form.application_references.last.referee_type).to eq('academic')
        expect(application_form.application_references.last.name).to eq('Walter White')
      end
    end

    context 'when a reference is passed in' do
      it 'updates the references type and name' do
        reference = create(:reference, referee_type: 'school-based', name: 'Jesse Pinkman')
        form = described_class.new(name: 'Walter White')
        form.save(application_form, 'academic', reference: reference)

        expect(reference.reload.referee_type).to eq('academic')
        expect(reference.reload.name).to eq('Walter White')
      end
    end
  end
end
