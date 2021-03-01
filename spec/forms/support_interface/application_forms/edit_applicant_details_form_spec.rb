require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditApplicantDetailsForm, type: :model do
  subject(:model) { described_class.new(application_form) }

  let(:application_form) { build(:application_form, :minimum_info) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:audit_comment) }

    it { is_expected.to validate_length_of(:first_name).is_at_most(60) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(60) }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }

    describe '#date_of_birth' do
      let(:application_form) { build(:application_form, :minimum_info, date_of_birth: date_of_birth) }
      let(:date_of_birth) { nil }

      include_examples 'date_of_birth validations', verify_presence: true
    end

    describe '#email_address' do
      it 'validates uniqueness' do
        existing_candidate = build(:candidate)
        allow(Candidate).to receive(:exists?).with(email_address: existing_candidate.email_address)
                                             .and_return(true)

        model.email_address = existing_candidate.email_address

        expect(model).to be_invalid
        expect(model.errors[:email_address]).to contain_exactly('Email address is already in use')
      end
    end
  end
end
