require 'rails_helper'

RSpec.describe DataMigrations::EndOfCycleCancelOutstandingReferences, sidekiq: true do
  context 'when apply 1' do
    let!(:application_form) do
      create(:application_form, :minimum_info, phase: 'apply_1')
    end

    context 'when feedback requested' do
      let!(:reference) do
        create(:reference, :feedback_requested, application_form: application_form)
      end

      context 'when unsubmitted' do
        let!(:application_choice) do
          create(:application_choice, :unsubmitted, application_form: application_form)
        end

        it 'cancels the reference' do
          described_class.new.change
          expect(reference.reload).to be_cancelled_at_end_of_cycle
        end

        it 'sends email to the referee' do
          described_class.new.change
          expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include(reference.email_address)
        end
      end

      context 'when conditions pending' do
        let!(:application_choice) do
          create(:application_choice, :with_accepted_offer, application_form: application_form)
        end

        it 'does not change' do
          described_class.new.change
          expect(reference.reload).to be_feedback_requested
        end
      end
    end

    context 'when feedback provided' do
      let!(:reference) do
        create(:reference, :feedback_provided, application_form: application_form)
      end
      let!(:application_choice) do
        create(:application_choice, :unsubmitted, application_form: application_form)
      end

      it 'does not change' do
        described_class.new.change
        expect(reference.reload).to be_feedback_provided
      end
    end
  end
end
