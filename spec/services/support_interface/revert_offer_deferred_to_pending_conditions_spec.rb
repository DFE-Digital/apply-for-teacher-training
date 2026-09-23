require 'rails_helper'

RSpec.describe SupportInterface::RevertOfferDeferredToPendingConditions, :with_audited do
  let(:application_choice) { create(:application_choice, :offer_deferred) }
  let(:zendesk_ticket) { 'becomingateacher.zendesk.com/agent/tickets/example' }

  describe '#save!' do
    it 'reverts the application choice status back to `pending_conditions` and sets an audit comment' do
      described_class.new(
        application_choice:,
        zendesk_ticket:,
      ).save!

      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      expect(application_choice.attributes.symbolize_keys).to match(
        a_hash_including({
          offer_deferred_at: nil,
          status_before_deferral: nil,
          status: 'pending_conditions',
        }),
      )
    end

    it 'updates the status of all conditions to pending' do
      application_choice.offer.conditions.update(status: :met)

      expect { described_class.new(application_choice:, zendesk_ticket:).save! }.to change { application_choice.offer.conditions.first.status }.from('met').to('pending')
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

        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
        expect(application_choice.attributes.symbolize_keys).to match(
          a_hash_including({
            offer_deferred_at: nil,
            status_before_deferral: nil,
            status: 'pending_conditions',
          }),
        )

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
