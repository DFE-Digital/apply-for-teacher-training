require 'rails_helper'

RSpec.describe CandidateInterface::Reference::RequestRefereeEmailAddressForm, type: :model do
  describe 'validations' do
    let(:form) { subject }

    context 'when a duplicate email is given' do
      let!(:application_form) { create(:application_form) }
      let!(:application_reference) { create(:reference, email_address: nil, application_form:) }

      context 'when duplicate reference is not sent' do
        it 'returns custom error message' do
          create(:reference, :not_requested_yet, email_address: 'iamtheone@whoknocks.com', application_form:)
          form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

          form.save(application_reference)
          expect(form.errors[:email_address]).to include('A reference request has already been started for this email address')
        end
      end

      context 'when duplicate reference is requested' do
        it 'returns custom error message' do
          create(:reference, :feedback_requested, email_address: 'iamtheone@whoknocks.com', application_form:)
          form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

          form.save(application_reference)
          expect(form.errors[:email_address]).to include('A reference request has already been sent to this email address')
        end
      end

      context 'when duplicate reference is received' do
        it 'returns custom error message' do
          create(:reference, :feedback_provided, email_address: 'iamtheone@whoknocks.com', application_form:)
          form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

          form.save(application_reference)
          expect(form.errors[:email_address]).to include('A reference has already been received from this email address')
        end
      end

      context 'when duplicate reference is not given' do
        it 'returns custom error message' do
          create(:reference, :feedback_refused, email_address: 'iamtheone@whoknocks.com', application_form:)
          form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

          form.save(application_reference)
          expect(form.errors[:email_address]).to include('The person using this email address said that they cannot give a reference')
        end
      end

      context 'when duplicate reference is bounced' do
        it 'returns custom error message' do
          create(:reference, :email_bounced, email_address: 'iamtheone@whoknocks.com', application_form:)
          form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

          form.save(application_reference)
          expect(form.errors[:email_address]).to include('A reference request already failed to reach this email address')
        end
      end

      context 'when duplicate reference is cancelled' do
        it 'returns custom error message' do
          %i[cancelled cancelled_at_end_of_cycle].each do |reference_status|
            create(:reference, reference_status, email_address: 'iamtheone@whoknocks.com', application_form:)
            form = described_class.new(email_address: 'iAMtheone@whoknocks.com', reference_id: application_reference.id)

            form.save(application_reference)
            expect(form.errors[:email_address]).to be_blank
            expect(application_reference.reload.email_address).to eq('iAMtheone@whoknocks.com')
          end
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
  end
end
