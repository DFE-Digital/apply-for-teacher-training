require 'rails_helper'

RSpec.describe SupportInterface::RevertRejection, :with_audited do
  describe '#save!' do
    let(:application_choice) { create(:application_choice, :rejected) }
    let(:zendesk_ticket) { 'becomingateacher.zendesk.com/agent/tickets/example' }

    it 'reverts the application choice status back to `awaiting_provider_decision` and sets an audit comment' do
      described_class.new(
        application_choice:,
        zendesk_ticket:,
      ).save!

      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      expect(application_choice.attributes.symbolize_keys).to match(
        a_hash_including({
          rejected_at: nil,
          structured_rejection_reasons: nil,
          rejection_reason: nil,
          rejection_reasons_type: nil,
          status: 'awaiting_provider_decision',
        }),
      )
    end

    context 'when the application form has a subsequent application form' do
      let(:application_form) { application_choice.application_form }

      it 'destroys the subsequent application form' do
        subsequent_application_form = create(
          :application_form,
          previous_application_form: application_form,
          recruitment_cycle_year: application_form.recruitment_cycle_year.next,
        )
        expect(application_form.reload.subsequent_application_form).to eq(subsequent_application_form)

        described_class.new(
          application_choice:,
          zendesk_ticket:,
        ).save!

        expect(application_form.reload.subsequent_application_form).to be_nil
      end

      context 'if the subsequent application form has application choices' do
        it 'does not destroy the subsequent application form' do
          subsequent_application_form = create(
            :application_form,
            previous_application_form: application_form,
            recruitment_cycle_year: application_form.recruitment_cycle_year.next,
          )
          create(:application_choice, application_form: subsequent_application_form)
          expect(application_form.reload.subsequent_application_form).to eq(subsequent_application_form)

          described_class.new(
            application_choice:,
            zendesk_ticket:,
          ).save!

          expect(application_form.reload.subsequent_application_form).to eq(subsequent_application_form)
        end
      end
    end
  end
end
