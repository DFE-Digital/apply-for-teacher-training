require 'rails_helper'

RSpec.describe CandidateInterface::AccountRecoveryForm, type: :model do
  before do
    FeatureFlag.activate(:one_login_candidate_sign_in)
  end

  subject(:form) do
    described_class.new(current_candidate:, code:)
  end

  let(:current_candidate) do
    create(:candidate, :with_live_session, account_recovery_request:)
  end
  let(:account_recovery_request) do
    create(
      :account_recovery_request,
      previous_account_email_address: old_candidate.email_address,
      codes: [account_recovery_request_code],
    )
  end
  let(:old_candidate) { create(:candidate, email_address: 'old@email.com') }
  let(:account_recovery_request_code) do
    create(
      :account_recovery_request_code,
      code: '001212',
    )
  end
  let(:code) { '001212' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_numericality_of(:code).only_integer }
    it { is_expected.to validate_length_of(:code) }

    context 'when code does not match' do
      let(:code) { '111111' }

      it 'returns invalid error if code is not found' do
        form.call

        expect(form).not_to be_valid
        expect(form.errors[:code]).to eq(
          ['This code is not recognised or it has expired, you can request a new one'],
        )
      end
    end

    context 'when code has expired' do
      let(:account_recovery_request_code) do
        create(
          :account_recovery_request_code,
          code: '001212',
          created_at: 2.hours.ago,
        )
      end

      it 'returns invalid error if code expired' do
        form.call

        expect(form).not_to be_valid
        expect(form.errors[:code]).to eq(
          ['This code is not recognised or it has expired, you can request a new one'],
        )
      end
    end

    it 'returns error if old account has one login already' do
      create(:one_login_auth, candidate: old_candidate)
      form.call

      expect(form).not_to be_valid
      expect(form.errors[:code]).to eq(
        ['The account you are trying to claim is already linked to a GOV.UK One Login. ' \
         'Use that email address to sign in to Apply for teacher training.'],
      )
    end
  end

  describe '#call' do
    it 'recovers the old candidate account' do
      expect { form.call }.to change { old_candidate.reload.account_recovery_status }.to('recovered')
        .and change { old_candidate.one_login_auth.present? }.to(true)

      expect { current_candidate.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when the candidate has signed up for an adviser' do
      it 'deletes the tta sign up and the candidate' do
        adviser_sign_up = create(:adviser_sign_up_request, application_form: current_candidate.current_application)

        form.call
        expect { current_candidate.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { adviser_sign_up.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the candidate has application_choices submitted' do
      it 'does not recover account and raises sentry error' do
        _previous_cycle_application_form = create(
          :application_form,
          :completed,
          candidate: current_candidate,
          recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
          previous_application_form: current_candidate.current_application,
          submitted_application_choices_count: 1,
        )
        allow(Sentry).to receive(:capture_exception)

        expect(form.call).to be(false)
        expect(old_candidate.reload.account_recovery_status).to eq('not_started')
        expect(old_candidate.one_login_auth.present?).to be(false)
        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end

  describe '#requested_new_code?' do
    it 'returns true if the candidate has more than 1 valid codes' do
      create(
        :account_recovery_request_code,
        account_recovery_request:,
        code: '222222',
      )

      expect(form.requested_new_code?).to be_truthy
    end

    it 'returns false if the candidate does not have more than 1 valid codes' do
      expect(form.requested_new_code?).to be_falsey
    end
  end
end
