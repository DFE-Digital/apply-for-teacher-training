require 'rails_helper'

RSpec.describe ReferenceActionsPolicy do
  describe '#editable?' do
    it 'is editable when the reference has not been requested yet' do
      reference = build(:reference, :not_requested_yet)

      expect(policy(reference).editable?).to be true
    end

    it 'is not editable in any other other state' do
      reference = build(:reference, :feedback_provided)

      expect(policy(reference).editable?).to be false
    end
  end

  describe '#can_send_reminder?' do
    it 'is true when state is feedback_requested and reminder_sent_at is nil' do
      reference = build(:reference, :feedback_requested, reminder_sent_at: nil)
      expect(policy(reference).can_send_reminder?).to be true
    end

    it 'is true when state is feedback_requested and last reminder was sent over 2 days ago' do
      reference = build(:reference, :feedback_requested, reminder_sent_at: (48.hours + 1.minute).ago)
      expect(policy(reference).can_send_reminder?).to be true
    end

    it 'is true when state is feedback_requested and last reminder was sent 3 days ago' do
      reference = build(:reference, :feedback_requested, reminder_sent_at: 3.days.ago)
      expect(policy(reference).can_send_reminder?).to be true
    end

    it 'is false when state is feedback_requested and last reminder was sent now' do
      reference = build(:reference, :feedback_requested, reminder_sent_at: Time.zone.now)
      expect(policy(reference).can_send_reminder?).to be false
    end

    it 'is false when state is feedback_requested and last reminder was sent 1 day ago' do
      reference = build(:reference, :feedback_requested, reminder_sent_at: 1.day.ago)
      expect(policy(reference).can_send_reminder?).to be false
    end

    it 'is false when state is not feedback_requested' do
      reference = build(:reference, :not_requested_yet, reminder_sent_at: nil)
      expect(policy(reference).can_send_reminder?).to be false
    end
  end

  describe '#can_be_destroyed?' do
    let(:unsubmitted_application_form) { build_stubbed(:application_form, submitted_at: nil) }
    let(:valid_states) { %i[not_requested_yet feedback_provided] }
    let(:invalid_states) { %i[cancelled cancelled_at_end_of_cycle email_bounced feedback_refused feedback_requested] }

    it 'returns true when the reference is in a state that can be destroyed and the application form has not been submitted' do
      valid_states.each do |state|
        reference = build_stubbed(:reference, state, application_form: unsubmitted_application_form)
        expect(policy(reference).can_be_destroyed?).to be true
      end
    end

    it 'returns false when the reference is in a state that cannot be destroyed' do
      invalid_states.each do |state|
        reference = build_stubbed(:reference, state, application_form: unsubmitted_application_form)
        expect(policy(reference).can_be_destroyed?).to be false
      end
    end

    it 'is false when in a state that has been can be destroyed, but the the application form has been submitted' do
      submitted_application_form = build_stubbed(:application_form, submitted_at: Time.zone.now)
      reference = build(:reference, valid_states.sample, application_form: submitted_application_form)
      expect(policy(reference).can_be_destroyed?).to be false
    end
  end

  describe '#request_can_be_deleted?' do
    let(:unsubmitted_application_form) { build_stubbed(:application_form, submitted_at: nil) }
    let(:valid_states) { %i[cancelled email_bounced feedback_refused] }
    let(:invalid_states) { %i[not_requested_yet feedback_provided cancelled_at_end_of_cycle feedback_requested] }

    it 'returns true when the reference is in a state that can be deleted and the application form has not been submitted' do
      valid_states.each do |state|
        reference = build_stubbed(:reference, state, application_form: unsubmitted_application_form)
        expect(policy(reference).request_can_be_deleted?).to be true
      end
    end

    it 'returns false when the reference is in a state that cannot be deleted' do
      invalid_states.each do |state|
        reference = build_stubbed(:reference, state, application_form: unsubmitted_application_form)
        expect(policy(reference).request_can_be_deleted?).to be false
      end
    end

    it 'is false when in a state that has been can be deleted, but the the application form has been submitted' do
      submitted_application_form = build_stubbed(:application_form, submitted_at: Time.zone.now)
      reference = build(:reference, valid_states.sample, application_form: submitted_application_form)
      expect(policy(reference).request_can_be_deleted?).to be false
    end
  end

  describe '#can_send?' do
    it 'is true reference is not_requested_yet' do
      reference = build(:reference, :not_requested_yet)
      expect(policy(reference).can_send?).to be true
    end

    it 'is true reference is feedback_requested' do
      reference = build(:reference, :feedback_requested)
      expect(policy(reference).can_send?).to be true
    end

    it 'is false reference is feedback_provided' do
      reference = build(:reference, :feedback_provided)
      expect(policy(reference).can_send?).to be false
    end
  end

  def policy(reference)
    ReferenceActionsPolicy.new(reference)
  end
end
