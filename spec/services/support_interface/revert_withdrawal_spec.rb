require 'rails_helper'

RSpec.describe SupportInterface::RevertWithdrawal, :with_audited do
  let(:zendesk_ticket) { 'becomingateacher.zendesk.com/agent/tickets/example' }

  describe '#save' do
    it 'reverts the application choice status back to `awaiting_provider_decision` and sets an audit comment' do
      application_choice = create(:application_choice, :awaiting_provider_decision, structured_withdrawal_reasons: %w[reason1 reason2 reason3])
      original_application_choice = application_choice.clone

      WithdrawApplication.new(
        application_choice:,
        accepted_offer: true,
      ).save!
      expect(application_choice.withdrawal_reasons.exists?).to be(true)

      described_class.new(application_choice:, zendesk_ticket:).save

      expect(application_choice).to eq(original_application_choice)
      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      expect(application_choice.withdrawn_or_declined_for_candidate_by_provider).to be_nil
      expect(application_choice.structured_withdrawal_reasons).to eq []
      expect(application_choice.withdrawal_reasons.exists?).to be(false)
    end
  end

  describe 'when reverting application results in duplicate course selection' do
    it 'adds errors to the application choice' do
      application_choice = create(:application_choice, :withdrawn)
      _withdrawal_reason = create(:withdrawal_reason, :published, application_choice:)
      course_option = application_choice.course_option
      application_form = application_choice.application_form
      create(:application_choice, :unsubmitted, application_form:, course_option:)

      described_class.new(application_choice:, zendesk_ticket:).save

      expect(application_choice.errors.full_messages).to include('cannot apply to the same course when an open application exists')
      expect(application_choice.withdrawal_reasons.exists?).to be(true)
    end
  end

  context 'when the application form has a subsequent application form' do
    it 'destroys the subsequent application form' do
      application_choice = create(:application_choice, :awaiting_provider_decision, structured_withdrawal_reasons: %w[reason1 reason2 reason3])
      application_form = application_choice.application_form
      subsequent_application_form = create(
        :application_form,
        previous_application_form: application_form,
        recruitment_cycle_year: application_form.recruitment_cycle_year.next,
      )
      expect(application_form.reload.subsequent_application_form).to eq(subsequent_application_form)
      original_application_choice = application_choice.clone

      WithdrawApplication.new(
        application_choice:,
        accepted_offer: true,
      ).save!
      expect(application_choice.withdrawal_reasons.exists?).to be(true)

      described_class.new(application_choice:, zendesk_ticket:).save

      expect(application_choice).to eq(original_application_choice)
      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      expect(application_choice.withdrawn_or_declined_for_candidate_by_provider).to be_nil
      expect(application_choice.structured_withdrawal_reasons).to eq []
      expect(application_choice.withdrawal_reasons.exists?).to be(false)

      expect(application_form.reload.subsequent_application_form).to be_nil
    end

    context 'if the subsequent application form has application choices' do
      it 'does not destroy the subsequent application form' do
        application_choice = create(:application_choice, :awaiting_provider_decision, structured_withdrawal_reasons: %w[reason1 reason2 reason3])
        application_form = application_choice.application_form
        subsequent_application_form = create(
          :application_form,
          previous_application_form: application_form,
          recruitment_cycle_year: application_form.recruitment_cycle_year.next,
        )
        create(:application_choice, application_form: subsequent_application_form)
        expect(application_form.reload.subsequent_application_form).to eq(subsequent_application_form)

        WithdrawApplication.new(
          application_choice:,
          accepted_offer: true,
        ).save!
        expect(application_choice.withdrawal_reasons.exists?).to be(true)

        described_class.new(application_choice:, zendesk_ticket:).save

        expect(application_form.reload.subsequent_application_form).to eq(subsequent_application_form)
      end
    end
  end
end
