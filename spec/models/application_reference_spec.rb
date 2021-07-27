require 'rails_helper'

RSpec.describe ApplicationReference, type: :model do
  subject { build(:reference) }

  describe 'auditing', with_audited: true do
    let(:application_form) { create(:application_form) }

    it { is_expected.to be_audited.associated_with :application_form }

    it 'creates an associated object in each audit record' do
      reference = create :reference, application_form: application_form
      expect(reference.audits.last.associated).to eq reference.application_form
    end

    it 'audit record can be attributed to a candidate' do
      candidate = create :candidate
      reference = Audited.audit_class.as_user(candidate) do
        create :reference, application_form: application_form
      end
      expect(reference.audits.last.user).to eq candidate
    end
  end

  describe '#refresh_feedback_token!' do
    let(:reference) { create(:reference, hashed_sign_in_token: 'old_hashed_token') }

    before do
      devise_token_generator = instance_double(Devise::TokenGenerator)
      allow(Devise).to receive(:token_generator).and_return(devise_token_generator)
      allow(devise_token_generator).to receive(:generate).and_return(%w[new_unhashed_token new_hashed_token])
    end

    it 'creates a new reference token' do
      reference.refresh_feedback_token!

      expect(reference.reference_tokens.first.hashed_token).to eq('new_hashed_token')
    end
  end

  describe '.find_by_unhashed_token' do
    before do
      devise_token_generator = instance_double(Devise::TokenGenerator)
      allow(Devise).to receive(:token_generator).and_return(devise_token_generator)
      allow(devise_token_generator).to receive(:digest).and_return('hashed_token')
    end

    context 'when the unhashed token does not match an unhashed sign in token on a reference' do
      it 'returns nil' do
        reference = described_class.find_by_unhashed_token('unhashed_token')

        expect(reference).to eq(nil)
      end
    end

    context 'when the unhashed token can be found in the reference token table' do
      it 'returns the reference' do
        chandler = create(:reference, name: 'Chandler Bing')
        create(:reference_token, application_reference: chandler, hashed_token: 'hashed_token')

        reference = described_class.find_by_unhashed_token('unhashed_token')

        expect(reference.name).to eq('Chandler Bing')
      end
    end
  end

  describe '#pending_feedback_or_failed' do
    it 'returns references in every state except not_requested_yet and feedback_provided' do
      expected_states = described_class.feedback_statuses.values - %w[not_requested_yet feedback_provided]
      expected_states.each { |s| create(:reference, feedback_status: s) }

      expect(described_class.pending_feedback_or_failed.size).to eq expected_states.size
    end
  end

  describe '#next_automated_chase_at' do
    context 'requested_at is nil' do
      it 'returns nil' do
        reference = build(:reference, requested_at: nil)
        expect(reference.next_automated_chase_at).to eq nil
      end
    end

    context 'current time is before first chase due date' do
      it 'returns first chase due date' do
        reference = build(:reference, requested_at: Time.zone.now)
        expect(reference.next_automated_chase_at).to eq reference.chase_referee_at
      end
    end

    context 'current time is after first chase due date' do
      it 'returns second chase due date' do
        reference = build(:reference, requested_at: Time.zone.now - TimeLimitConfig.chase_referee_by.days)
        expect(reference.next_automated_chase_at).to eq reference.additional_chase_referee_at
      end
    end

    context 'current time is after second chase due date' do
      it 'returns nil' do
        reference = build(:reference, requested_at: Time.zone.now - TimeLimitConfig.additional_reference_chase_calendar_days.days)
        expect(reference.next_automated_chase_at).to eq nil
      end
    end
  end
end
