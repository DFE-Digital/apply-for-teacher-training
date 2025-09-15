require 'rails_helper'

RSpec.describe RefereeInterface::ConfirmRefuseFeedbackForm do
  describe '#save' do
    let(:application_reference) { create(:reference, :feedback_requested) }

    context 'when the form is valid' do
      it 'updates the reference to feedback_refused and sets the feedback_refused_at to the current time' do
        form = described_class.new
        form.save(application_reference)

        expect(application_reference.feedback_status).to eq('feedback_refused')
        expect(application_reference.feedback_refused_at).to eq(Time.zone.now)
      end
    end
  end
end
