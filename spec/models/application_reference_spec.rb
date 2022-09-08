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

  describe '.referees_to_chase' do
    context 'when between apply 1 deadline and find has opened' do
      around do |example|
        Timecop.travel(CycleTimetable.apply_1_deadline(2022) + 1.day) { example.run }
      end

      it 'returns requested references for candidates on apply 2 only for the current cycle' do
        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2022)
        create(:reference, :feedback_requested, application_form: application_form, requested_at: CycleTimetable.apply_1_deadline - 7.days)

        application_form_apply_again = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_2')
        first_reference_apply_again = create(:reference, :feedback_requested, application_form: application_form_apply_again, requested_at: 8.days.ago)
        second_reference_apply_again = create(:reference, :feedback_requested, application_form: application_form_apply_again, requested_at: 8.days.ago)

        application_form_next_cycle =  create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        create(:reference, :feedback_requested, application_form: application_form_next_cycle, requested_at: CycleTimetable.apply_1_deadline - 7.days)

        references = described_class.referees_to_chase(
          chase_referee_by: 7.days.before(Time.zone.now),
          rejected_chased_ids: [second_reference_apply_again.id],
        )

        expect(references).to match_array([first_reference_apply_again])
      end
    end

    context 'when between apply has opened and the apply 1 deadline' do
      around do |example|
        Timecop.travel(CycleTimetable.find_reopens(2023) + 7.days) { example.run }
      end

      it 'returns requested references in last days of current recruiment cycle' do
        old_application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_1')
        create(:reference, :feedback_requested, application_form: old_application_form, requested_at: CycleTimetable.find_reopens(2023) - 7.days)

        old_application_form_apply_again = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_2')
        create(:reference, :feedback_requested, application_form: old_application_form_apply_again, requested_at: CycleTimetable.find_reopens(2023) - 7.days)

        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        reference = create(:reference, :feedback_requested, application_form: application_form, requested_at: CycleTimetable.find_reopens(2023))

        references = described_class.referees_to_chase(
          chase_referee_by: 7.days.before(Time.zone.now),
          rejected_chased_ids: [],
        )
        expect(references).to match_array([reference])
      end
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

        expect(reference).to be_nil
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

  describe '.find_latest_reference' do
    it 'returns the latest duplicated reference' do
      application_form1 = create(:application_form)
      application_form2 = create(:application_form, candidate: application_form1.candidate)
      reference1 = create(:reference, :feedback_requested, application_form: application_form1)
      reference2 = create(:reference,
                          :feedback_requested,
                          name: reference1.name,
                          email_address: reference1.email_address,
                          relationship: reference1.relationship,
                          application_form: application_form2)

      expect(reference1.find_latest_reference).to eq reference2
    end
  end

  describe '#failed' do
    it 'returns references that have been unsuccessful (bounced, refused or cancelled)' do
      described_class.feedback_statuses.each_value { |status| create(:reference, feedback_status: status) }

      expected_states = %w[cancelled cancelled_at_end_of_cycle feedback_refused]
      expect(described_class.failed.collect(&:feedback_status)).to match_array(expected_states)
    end
  end

  describe '#next_automated_chase_at' do
    context 'requested_at is nil' do
      it 'returns nil' do
        reference = build(:reference, requested_at: nil)
        expect(reference.next_automated_chase_at).to be_nil
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
        expect(reference.next_automated_chase_at).to be_nil
      end
    end
  end
end
