require 'rails_helper'

RSpec.describe CandidateInterface::AccountRecoveryRequestForm, type: :model do
  subject(:form) do
    described_class.new(
      current_candidate:,
      previous_account_email_address:,
    )
  end

  let(:current_candidate) do
    create(:candidate, :with_live_session)
  end
  let(:account_recovery_request) do
    create(
      :account_recovery_request,
      previous_account_email_address: old_candidate.email_address,
    )
  end
  let!(:old_candidate) { create(:candidate) }
  let(:previous_account_email_address) { 'old@email.com' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:previous_account_email_address) }

    context 'when previous_account_email_address matches the current candidate' do
      let(:previous_account_email_address) do
        current_candidate.email_address
      end

      it 'is invalid if previous email matches current_candidate email' do
        form.save_and_email_candidate

        expect(form).not_to be_valid
        expect(form.errors[:previous_account_email_address]).to eq(
          ['Enter the email address you use to sign in to Apply for teacher training'],
        )
      end
    end
  end

  describe '#save_and_email_candidate' do
    context 'with old candidate existing in our DB' do
      let!(:old_candidate) do
        create(:candidate, email_address: previous_account_email_address)
      end

      it 'creates an account_recovery_request and sends email to candidate' do
        expect { form.save_and_email_candidate }.to change { current_candidate.account_recovery_request.present? }.to(true)
          .and change { AccountRecoveryRequestCode.count }.by(1)
          .and have_enqueued_mail(AccountRecoveryMailer, :send_code)

        expect(current_candidate.account_recovery_request.codes.present?).to be_truthy
      end
    end

    context 'with old not existing in our DB' do
      it 'creates an account_recovery_request and sends email to candidate' do
        expect { form.save_and_email_candidate }.to change { current_candidate.account_recovery_request.present? }.to(true)
          .and change { AccountRecoveryRequestCode.count }.by(1)

        expect(current_candidate.account_recovery_request.codes.present?).to be_truthy
        expect { form.save_and_email_candidate }.not_to have_enqueued_mail(AccountRecoveryMailer, :send_code)
        expect(form.save_and_email_candidate).to be_truthy
      end
    end

    context 'when the candidate attempts to create multiple recovery requests' do
      it 'creates an account_recovery_request and sends email to candidate' do
        form.save_and_email_candidate
        form.save_and_email_candidate

        expect(AccountRecoveryRequest.where(candidate: current_candidate).count).to eq(1)
      end
    end
  end
end
