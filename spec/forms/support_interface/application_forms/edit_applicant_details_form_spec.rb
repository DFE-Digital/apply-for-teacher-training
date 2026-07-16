require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditApplicantDetailsForm, type: :model do
  subject(:model) { described_class.new(application_form) }

  let(:application_form) { build(:application_form, :minimum_info) }

  describe 'validations' do
    it_behaves_like 'an email address valid for notify'

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:audit_comment) }

    it { is_expected.to validate_length_of(:first_name).is_at_most(60) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(60) }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }

    it 'validates with SafeChoiceUpdateValidator' do
      expect(model.class.validators.map(&:class)).to include(SafeChoiceUpdateValidator)
    end

    describe '#date_of_birth' do
      let(:application_form) { build(:application_form, :minimum_info, date_of_birth:) }
      let(:date_of_birth) { nil }

      it_behaves_like 'date_of_birth validations', verify_presence: true
    end

    describe '#email_address' do
      it 'validates uniqueness' do
        existing_candidate = build(:candidate)
        allow(Candidate).to receive(:exists?).with(email_address: existing_candidate.email_address)
                                             .and_return(true)

        model.email_address = existing_candidate.email_address

        expect(model).not_to be_valid
        expect(model.errors[:email_address]).to contain_exactly('Email address is already in use')
      end
    end
  end

  describe '#save!' do
    let(:attributes) do
      {
        first_name: 'Cloud',
        last_name: 'Strife',
        email_address: 'cloud.strife@example.com',
        phone_number: '99999 1111111',
        audit_comment: 'Audit comment',
      }
    end

    it 'updates the attributes of an application form' do
      model.assign_attributes(attributes)
      model.save!
      expect(application_form.reload).to have_attributes(attributes.except(:email_address, :audit_comment))
      expect(application_form.candidate.reload.email_address).to eq('cloud.strife@example.com')
    end

    context 'when given previous last names' do
      let(:attributes) do
        {
          first_name: 'Gandalf',
          last_name: 'The White',
          previous_last_names: 'The Grey',
          email_address: 'gandalf.the.white@example.com',
          phone_number: '99999 1111111',
          audit_comment: 'Audit comment',
        }
      end

      it 'updates the attributes of an application form' do
        model.assign_attributes(attributes)
        model.save!
        expect(application_form.reload).to have_attributes(attributes.except(:email_address, :audit_comment))
        expect(application_form.candidate.reload.email_address).to eq('gandalf.the.white@example.com')
      end
    end
  end
end
