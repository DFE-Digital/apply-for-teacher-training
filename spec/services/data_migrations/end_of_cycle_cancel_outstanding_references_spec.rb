require 'rails_helper'

RSpec.describe DataMigrations::EndOfCycleCancelOutstandingReferences, :sidekiq do
  context 'when 2021' do
    it 'cancels references' do
      application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2021)
      reference = create(:reference, :feedback_requested, application_form: application_form)
      described_class.new.change
      expect(reference.reload).to be_cancelled_at_end_of_cycle
    end
  end

  context 'when 2023' do
    it 'does not change' do
      application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
      reference = create(:reference, :feedback_requested, application_form: application_form)
      described_class.new.change
      expect(reference.reload).to be_feedback_requested
    end
  end

  context 'when 2022' do
    let!(:application_form) do
      create(:application_form, :minimum_info, recruitment_cycle_year: 2022)
    end

    context 'when feedback requested' do
      let!(:reference) do
        create(:reference, :feedback_requested, application_form: application_form)
      end
      let!(:application_choice) do
        create(:application_choice, :unsubmitted, application_form: application_form)
      end

      it 'cancels the reference' do
        described_class.new.change
        expect(reference.reload).to be_cancelled_at_end_of_cycle
      end

      it 'does not send email to referee' do
        described_class.new.change
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to eq([])
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
