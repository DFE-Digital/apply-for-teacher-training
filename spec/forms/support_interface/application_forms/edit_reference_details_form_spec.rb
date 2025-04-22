require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditReferenceDetailsForm do
  let(:reference) { create(:reference, name: 'John Doe', email_address: 'john.doe@example.com', relationship: 'Colleague', confidential: true) }

  describe 'validations' do
    subject { described_class.new }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to allow_value('john.doe@example.com').for(:email_address) }
    it { is_expected.not_to allow_value('invalid-email').for(:email_address) }
    it { is_expected.to validate_presence_of(:relationship) }
    it { is_expected.to validate_presence_of(:audit_comment) }
    it { is_expected.to validate_presence_of(:confidential).with_message('Select whether or not the feedback may be shared with the candidate') }
  end

  describe '.build_from_reference' do
    it 'initializes the form with details from the reference' do
      form = described_class.build_from_reference(reference)

      expect(form.name).to eq('John Doe')
      expect(form.email_address).to eq('john.doe@example.com')
      expect(form.relationship).to eq('Colleague')
      expect(form.confidential).to be true
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(valid_attributes) }

    let(:valid_attributes) do
      {
        name: 'Jane Doe',
        email_address: 'jane.doe@example.com',
        relationship: 'Manager',
        audit_comment: 'Updated reference details',
        confidential: 'false',
      }
    end

    context 'when form is from this cycle' do
      it 'updates the reference with the provided attributes' do
        form.save(reference)
        reference.reload
        expect(reference.name).to eq('Jane Doe')
        expect(reference.email_address).to eq('jane.doe@example.com')
        expect(reference.relationship).to eq('Manager')
        expect(reference.confidential).to be false
      end
    end

    context 'when from old cycle' do
      let(:application_form) do
        create(
          :application_form,
          :with_accepted_offer,
          recruitment_cycle_year: previous_year,
        )
      end
      let(:reference) do
        ApplicationForm.with_unsafe_application_choice_touches do
          create(:reference, :feedback_requested, application_form:)
        end
      end

      before do
        RequestStore.store[:allow_unsafe_application_choice_touches] = false
      end

      it 'updates the reference with the provided attributes' do
        form.save(reference)
        reference.reload
        expect(reference.name).to eq('Jane Doe')
        expect(reference.email_address).to eq('jane.doe@example.com')
        expect(reference.relationship).to eq('Manager')
        expect(reference.confidential).to be false
      end
    end
  end
end
