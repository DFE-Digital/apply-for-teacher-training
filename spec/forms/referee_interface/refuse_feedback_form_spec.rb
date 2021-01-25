require 'rails_helper'

RSpec.describe RefereeInterface::RefuseFeedbackForm do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:choice) }

    describe '#save' do
      let(:application_reference) { create(:reference, :feedback_requested) }

      context 'when the form is invalid' do
        it 'returns false' do
          form = described_class.new

          expect(form.save(application_reference)).to be(false)
        end
      end

      context 'when the form is valid' do
        it 'updates the reference to feedback_refused and sets the feedback_refused_at to the current time' do
          Timecop.freeze do
            form = described_class.new(choice: 'yes')
            form.save(application_reference)

            expect(application_reference.feedback_status).to eq('feedback_refused')
            expect(application_reference.feedback_refused_at).to eq(Time.zone.now)
          end
        end
      end
    end
  end
end
