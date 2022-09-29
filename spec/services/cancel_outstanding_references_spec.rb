require 'rails_helper'

RSpec.describe CancelOutstandingReferences, sidekiq: true do
  let(:service) { described_class.new(application_form: application_form) }

  context 'when an application has requested references in the new cycle' do
    let(:application_form) { create(:application_form, :minimum_info, recruitment_cycle_year: 2023) }
    let!(:requested_reference) { create(:reference, :feedback_requested, application_form: application_form) }
    let!(:provided_reference) { create(:reference, :feedback_provided, application_form: application_form) }

    before do
      FeatureFlag.activate(:new_references_flow)
    end

    it 'cancel the requested references' do
      service.call!

      expect(requested_reference.reload.feedback_status).to eq('cancelled')
      expect(provided_reference.reload.feedback_status).to eq('feedback_provided')
    end

    it 'deliver email to requested references' do
      service.call!

      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array([requested_reference.email_address])
    end
  end

  context 'when the application is from the old cycle' do
    let(:application_form) { create(:application_form, :minimum_info, recruitment_cycle_year: 2022) }

    it 'does not cancel any reference' do
      requested_reference = create(:reference, :feedback_requested, application_form: application_form)

      service.call!

      expect(requested_reference.reload.feedback_status).to eq('feedback_requested')
    end
  end
end
