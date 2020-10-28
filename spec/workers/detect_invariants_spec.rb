require 'rails_helper'

RSpec.describe DetectInvariants do
  before { allow(Raven).to receive(:capture_exception) }

  describe '#perform' do
    it 'detects weird references state' do
      application_choice_bad = create(:application_choice)
      application_choice_bad.update_columns(status: 'application_complete')
      application_choice_bad_too = create(:application_choice)
      application_choice_bad_too.update_columns(status: 'awaiting_references')

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::WeirdSituationDetected.new(
          <<~MSG,
            One or more application choices are still in `awaiting_references` or
            `application_complete` state, but all these states have been removed:

            #{application_choice_bad.id}
            #{application_choice_bad_too.id}
          MSG
        ),
      )
    end
  end
end
