require 'rails_helper'

RSpec.describe ApplicationReference, type: :model do
  subject { build(:reference) }

  describe 'a valid reference' do
    before do
      FeatureFlag.deactivate('decoupled_references')
    end

    let(:candidate) { build(:candidate) }
    let(:application_form) { build(:application_form, candidate: candidate) }

    subject { build(:reference, application_form: application_form) }

    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
    it { is_expected.to validate_uniqueness_of(:email_address).scoped_to(:application_form_id).ignoring_case_sensitivity }

    context 'when a candidate uses their own email address' do
      it 'adds an error' do
        reference = build(:reference, application_form: application_form, email_address: candidate.email_address)

        expect(reference.valid?).to eq(false)
        expect(reference.errors.full_messages_for(:email_address)).to eq(
          ["Email address #{t('activerecord.errors.models.application_reference.attributes.email_address.own')}"],
        )
      end
    end

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }

    valid_text = Faker::Lorem.sentence(word_count: 50)
    invalid_text = Faker::Lorem.sentence(word_count: 51)

    it { is_expected.to allow_value(valid_text).for(:relationship) }
    it { is_expected.not_to allow_value(invalid_text).for(:relationship) }
  end

  describe 'saving a new reference' do
    context 'when there is no existing reference on the same application_form' do
      let!(:application_form) { create(:application_form) }
      let(:new_reference) { build(:reference, application_form: application_form) }

      it 'sets the ordinal to 1' do
        new_reference.save!
        expect(new_reference.ordinal).to eq(1)
      end
    end

    context 'when there is an existing reference on the same application_form' do
      let!(:application_form) { create(:application_form) }
      let(:new_reference) { build(:reference) }

      before do
        create(:reference, application_form: application_form)
        application_form.application_references << new_reference
      end

      it 'sets the ordinal to 2' do
        new_reference.save!
        expect(new_reference.ordinal).to eq(2)
      end
    end
  end

  # potential edge case: someone adds 2 references, then deletes the first
  # we want to make sure it updates the ordinal of the remaining second ref. to
  # be 1, so that we can still use that to describe 'First referee' etc in the
  # interface
  describe 'after deleting a reference' do
    let!(:application_form) { create(:completed_application_form, references_count: 2, with_gcses: true) }

    describe 'the ordinal of the remaining references' do
      let(:ordinals) { application_form.application_references.map(&:ordinal) }

      it 'still starts at 1' do
        application_form.application_references.first.destroy
        expect(ordinals.first).to eq(1)
      end
    end
  end

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
        reference = ApplicationReference.find_by_unhashed_token('unhashed_token')

        expect(reference).to eq(nil)
      end
    end

    context 'when the unhashed token can be found in the reference token table' do
      it 'returns the reference' do
        chandler = create(:reference, name: 'Chandler Bing')
        create(:reference_token, application_reference: chandler, hashed_token: 'hashed_token')

        reference = ApplicationReference.find_by_unhashed_token('unhashed_token')

        expect(reference.name).to eq('Chandler Bing')
      end
    end
  end

  describe '#editable?' do
    it 'returns true for `not_requested_yet`' do
      expect(described_class.new(feedback_status: :not_requested_yet).editable?).to be true
    end

    it 'returns false for all other statuses' do
      ApplicationReference.feedback_statuses.keys.reject { |s| s == 'not_requested_yet' }.each do |status|
        expect(described_class.new(feedback_status: status).editable?).to be false
      end
    end
  end

  describe '#pending_feedback_or_failed' do
    it 'returns references in every state except not_requested_yet and feedback_provided' do
      expected_states = ApplicationReference.feedback_statuses.values - %w[not_requested_yet feedback_provided]
      expected_states.each { |s| create(:reference, feedback_status: s) }

      expect(ApplicationReference.pending_feedback_or_failed.size).to eq expected_states.size
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

  describe '#can_send_reminder?' do
    it 'is true when state is feedback_requested and reminder_sent_at is nil' do
      reference = build(:reference, :feedback_requested, reminder_sent_at: nil)
      expect(reference.can_send_reminder?).to eq true
    end

    it 'is false when state is not feedback_requested' do
      reference = build(:reference, :not_requested_yet, reminder_sent_at: nil)
      expect(reference.can_send_reminder?).to eq false
    end

    it 'is false when reminder_sent_at is filled' do
      reference = build(:reference, :feedback_requested, reminder_sent_at: Time.zone.now)
      expect(reference.can_send_reminder?).to eq false
    end
  end

  describe '#can_be_destroyed??' do
    let(:unsubmitted_application_form) { build_stubbed(:application_form, submitted_at: nil) }
    let(:submitted_application_form) { build_stubbed(:application_form, submitted_at: Time.zone.now) }

    it 'is true when state is not_requested_yet and the application form has not been submitted' do
      reference = build_stubbed(:reference, :not_requested_yet, application_form: unsubmitted_application_form)
      expect(reference.can_be_destroyed?).to eq true
    end

    it 'is true when state is feedback_provided and the application form has not been submitted' do
      reference = build(:reference, :feedback_provided, application_form: unsubmitted_application_form)
      expect(reference.can_be_destroyed?).to eq true
    end

    it 'is false when state is feedback_requested state aand the application form has not been submitted' do
      reference = build(:reference, :feedback_requested, application_form: unsubmitted_application_form)
      expect(reference.can_be_destroyed?).to eq false
    end

    it 'is false when state is not_requested_yet and the application form has been submitted' do
      reference = build(:reference, :not_requested_yet, application_form: submitted_application_form)
      expect(reference.can_be_destroyed?).to eq false
    end

    it 'is false when state is feedback_provided and the application form has been submitted' do
      reference = build(:reference, :feedback_provided, application_form: submitted_application_form)
      expect(reference.can_be_destroyed?).to eq false
    end
  end
end
