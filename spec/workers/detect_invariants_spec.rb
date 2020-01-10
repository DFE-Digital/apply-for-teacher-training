require 'rails_helper'

RSpec.describe DetectInvariants do
  before { allow(Raven).to receive(:capture_exception) }

  describe '#perform' do
    it 'detects weird references state' do
      application_choice = create(:application_choice, status: 'application_complete')
      create(:reference, :complete, application_form: application_choice.application_form)
      create(:reference, :complete, application_form: application_choice.application_form)

      application_choice = create(:application_choice, status: 'awaiting_references')
      create(:reference, :complete, application_form: application_choice.application_form)
      create(:reference, :complete, application_form: application_choice.application_form)

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::WeirdSituationDetected.new(
          <<~MSG,
            One or more application choices in `awaiting_references` state, but all feedback is collected:

            #{application_choice.id}
          MSG
      ),
)
    end
  end
end
