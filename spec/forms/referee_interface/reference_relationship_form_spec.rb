require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceRelationshipForm, type: :model do
  describe '#build_from_application' do
    it 'creates an object based on the application reference' do
      reference = build_stubbed(:reference, relationship_correction: 'Leader of the MS Paint course')
      form = described_class.build_from_reference(reference: reference)

      expect(form.relationship_correction).to eq('Leader of the MS Paint course')
    end

    context 'when there is no relationship_correction' do
      it 'sets the relationship_confirmation true' do
        reference = build_stubbed(:reference, relationship_correction: '')
        form = described_class.build_from_reference(reference: reference)

        expect(form.relationship_confirmation).to eq('yes')
      end
    end

    context 'when there is a relationship_correction' do
      it 'sets the relationship_confirmation false' do
        reference = build_stubbed(:reference, relationship_correction: 'She did not attend my MS Paint course')
        form = described_class.build_from_reference(reference: reference)

        expect(form.relationship_confirmation).to eq('no')
      end
    end

    context 'when there is a relationship_correction is nil' do
      it 'sets the relationship_confirmation nil' do
        reference = build_stubbed(:reference)
        form = described_class.build_from_reference(reference: reference)

        expect(form.relationship_confirmation).to eq(nil)
      end
    end
  end

  describe '#save' do
    let(:application_reference) { create(:reference) }

    context 'when relationship_confirmation is blank' do
      it 'return false' do
        form = described_class.new

        expect(form.save(application_reference)).to be(false)
      end
    end

    context 'when relationship_confirmation has value "no"' do
      it 'updates the application reference with the correction' do
        form = described_class.new(relationship_confirmation: 'no', relationship_correction: 'I dont know this person')

        form.save(application_reference)

        expect(application_reference.relationship_correction).to eq('I dont know this person')
      end
    end

    context 'when relationship_confirmation has value "yes' do
      it 'resets the relationship_correction' do
        form = described_class.new(relationship_confirmation: 'yes')

        form.save(application_reference)

        expect(application_reference.relationship_correction).to eq('')
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:relationship_confirmation) }

    context 'when relationship_confirmation has value "no"' do
      it 'validates presence of relationship_correction' do
        form = described_class.new(relationship_confirmation: 'no', candidate: 'Tim Tamagotchi')
        expected_error_message = I18n.t('activemodel.errors.models.referee_interface/reference_relationship_form.attributes.relationship_correction.blank', candidate: 'Tim Tamagotchi')

        form.validate

        expect(form.errors.full_messages_for(:relationship_correction)).to eq(
          ["Relationship correction #{expected_error_message}"],
        )
      end

      it 'does not show error when there is relationship_correction' do
        form = described_class.new(relationship_correction: 'Fixed')
        form.validate

        expect(form.errors.full_messages_for(:relationship_correction)).to be_empty
      end
    end
  end
end
