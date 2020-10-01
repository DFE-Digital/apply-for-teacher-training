require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RefereeEmailAddressForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email_address) }
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

    before do
      FeatureFlag.activate('decoupled_references')
    end

    context 'when email_address is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_reference)).to be(false)
      end
    end

    context 'when email_address has a value' do
      it 'creates the referee' do
        form = described_class.new(email_address: 'iamtheone@whoknocks.com')
        form.save(application_reference)

        expect(application_reference.email_address).to eq('iamtheone@whoknocks.com')
      end
    end
  end
end
