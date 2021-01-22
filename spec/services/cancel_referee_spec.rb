require 'rails_helper'

RSpec.describe CancelReferee do
  describe '#call' do
    it 'updates the reference state to "cancelled" and sets cancelled_at to the current time' do
      Timecop.freeze do
        reference = create(:reference, :feedback_requested)

        described_class.new.call(reference: reference)

        expect(reference).to be_cancelled
        expect(reference.cancelled_at).to eq Time.zone.now
      end
    end
  end
end
