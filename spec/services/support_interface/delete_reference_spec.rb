require 'rails_helper'

RSpec.describe SupportInterface::DeleteReference, :with_audited do
  let(:actor) { create(:support_user) }
  let(:zendesk_url) { 'https://becomingateacher.zendesk.com/agent/tickets/123456' }

  describe '#call!' do
    it 'deletes the reference' do
      reference = create(:reference, :feedback_provided)

      described_class.new.call!(actor:, reference:, zendesk_url:)

      expect { reference.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when the application is from a previous cycle' do
      let(:application_form) do
        create(
          :application_form,
          :with_accepted_offer,
          recruitment_cycle_year: previous_year,
        )
      end
      let(:reference) do
        ApplicationForm.with_unsafe_application_choice_touches do
          create(:reference, :feedback_provided, application_form:)
        end
      end

      before do
        reference
        RequestStore.store[:allow_unsafe_application_choice_touches] = false
      end

      it 'deletes the reference without raising an error' do
        expect { described_class.new.call!(actor:, reference:, zendesk_url:) }.not_to raise_error
        expect(ApplicationReference.exists?(reference.id)).to be(false)
      end
    end
  end
end
