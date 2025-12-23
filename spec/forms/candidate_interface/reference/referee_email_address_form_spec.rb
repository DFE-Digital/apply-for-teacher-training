require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RefereeEmailAddressForm, type: :model do
  shared_examples_for 'custom email address error message' do |feedback_status, error_message|
    it 'returns custom error message' do
      create(:reference, feedback_status, email_address: 'iamtheone@whoknocks.com', application_form:)
      form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

      form.save(application_reference)
      expect(form.errors[:email_address]).to include(error_message)
    end
  end

  describe 'validations' do
    let(:form) { subject }

    # Only applies to the `it {}` short form validation tests
    before do
      allow(form).to receive_messages(email_address_unique: true, email_address_not_own: true)
    end

    it_behaves_like 'an email address valid for notify'

    it { is_expected.to validate_presence_of(:email_address) }

    one_hundred_character_email = "#{SecureRandom.hex(44)}@example.com"
    one_hundred_and_one_character_email = "#{SecureRandom.hex(45)}@example.com"

    it { is_expected.to allow_value(one_hundred_character_email).for(:email_address) }
    it { is_expected.not_to allow_value(one_hundred_and_one_character_email).for(:email_address) }

    context 'when a duplicate email is given' do
      let!(:application_form) { create(:application_form) }
      let!(:application_reference) { create(:reference, email_address: nil, application_form:) }

      it_behaves_like 'custom email address error message', :not_requested_yet, 'A reference request has already been started for this email address'
      it_behaves_like 'custom email address error message', :feedback_requested, 'A reference request has already been sent to this email address'
      it_behaves_like 'custom email address error message', :feedback_provided, 'A reference has already been received from this email address'
      it_behaves_like 'custom email address error message', :feedback_refused, 'The person using this email address said that they cannot give a reference'
      it_behaves_like 'custom email address error message', :email_bounced, 'A reference request already failed to reach this email address'

      context 'when duplicate reference is cancelled' do
        it 'returns custom error message' do
          %i[cancelled cancelled_at_end_of_cycle].each do |reference_status|
            create(:reference, reference_status, email_address: 'iamtheone@whoknocks.com', application_form:)
            form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

            form.save(application_reference)
            expect(form.errors[:email_address]).to be_blank
            expect(application_reference.reload.email_address).to eq('iamtheone@whoknocks.com')
          end
        end
      end

      context 'when application has blank email address' do
        it 'ignores incomplete references' do
          create(:reference, :feedback_requested, email_address: nil, application_form:)
          form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

          form.save(application_reference)
          expect(form).to be_valid
        end

        it 'ignores blank' do
          reference = create(:reference, :feedback_requested, email_address: nil, application_form:)
          form = described_class.new(email_address: '', reference_id: reference.id)

          form.save(application_reference)
          expect(form.errors.any? { |error| error.type =~ /duplicate/ }).to be_falsey
        end
      end
    end

    context 'when no email is given' do
      it 'is not valid' do
        application_reference = create(:reference, email_address: nil)
        form = described_class.build_from_reference(application_reference)

        expect(form).not_to be_valid
      end
    end

    context "when the candidate's email is given" do
      it 'is not valid' do
        application_form = create(:application_form)
        candidate_email_address = application_form.candidate.email_address
        application_reference = create(:reference, email_address: nil, application_form:)
        form = described_class.new(email_address: candidate_email_address, reference_id: application_reference.id)

        expect(form).not_to be_valid
      end
    end

    describe '.build_from_reference' do
      it 'creates an object based on the reference' do
        application_reference = create(:reference, email_address: 'iAmTheOne@whoknocks.com')
        form = described_class.build_from_reference(application_reference)

        expect(form.email_address).to eq('iamtheone@whoknocks.com')
        expect(form.reference_id).to eq application_reference.id
      end
    end

    describe '#save' do
      let(:application_reference) { create(:reference) }

      context 'when email_address has a value' do
        it 'creates the referee' do
          form = described_class.new(email_address: 'iamtheone@whoknocks.com', reference_id: application_reference.id)
          form.save(application_reference)

          expect(application_reference.email_address).to eq('iamtheone@whoknocks.com')
        end
      end
    end
  end
end
