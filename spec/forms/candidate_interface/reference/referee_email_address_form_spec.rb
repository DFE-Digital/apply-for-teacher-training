require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RefereeEmailAddressForm, type: :model do
  before do
    FeatureFlag.activate('decoupled_references')
  end

  describe 'validations' do
    let(:form) { subject }

    before do
      allow(form).to receive(:email_address_unique?).and_return true
    end

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_presence_of(:application_form_id) }

    one_hundred_character_email = "#{SecureRandom.hex(44)}@example.com"
    one_hundred_and_two_character_email = "#{SecureRandom.hex(45)}@example.com"

    it { is_expected.to allow_value(one_hundred_character_email).for(:email_address) }
    it { is_expected.not_to allow_value(one_hundred_and_two_character_email).for(:email_address) }

    context 'when a duplicate email is given' do
      it 'is not valid' do
        application_form = create(:application_form)
        create(:reference, email_address: 'iamtheone@whoknocks.com', application_form: application_form)
        application_reference = create(:reference, email_address: nil)

        form = described_class.new(email_address: 'iamtheone@whoknocks.com', application_form_id: application_form.id)
        expect(form.save(application_reference)).to be(false)
      end
    end
  end

  describe '.build_from_reference' do
    it 'creates an object based on the reference' do
      application_reference = build_stubbed(:reference, email_address: 'iamtheone@whoknocks.com')
      form = described_class.build_from_reference(application_reference)

      expect(form.email_address).to eq('iamtheone@whoknocks.com')
    end
  end

  describe '#save' do
    let(:application_reference) { create(:reference) }

    context 'when email_address has a value' do
      it 'creates the referee' do
        form = described_class.new(email_address: 'iamtheone@whoknocks.com', application_form_id: application_reference.application_form.id)
        form.save(application_reference)

        expect(application_reference.email_address).to eq('iamtheone@whoknocks.com')
      end
    end
  end
end
