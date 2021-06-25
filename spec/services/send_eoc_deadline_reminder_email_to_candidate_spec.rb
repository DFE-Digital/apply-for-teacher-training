require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidate do
  describe '#call' do
    context 'when the candidate is in Apply 1' do
      let(:application_form) { create(:application_form, phase: 'apply_1') }

      it 'sends a reminder email to the candidate' do
        described_class.call(application_form: application_form)
        expect(application_form.chasers_sent.eoc_deadline_reminder.count).to eq(1)
      end
    end

    context 'when the candidate is in Apply 2' do
      let(:application_form) { create(:application_form, phase: 'apply_2') }

      it 'sends a reminder email to the candidate' do
        described_class.call(application_form: application_form)
        expect(application_form.chasers_sent.eoc_deadline_reminder.count).to eq(1)
      end
    end
  end
end
