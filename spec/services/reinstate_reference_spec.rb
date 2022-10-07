require 'rails_helper'

RSpec.describe ReinstateReference, sidekiq: true do
  describe '#call' do
    it 'requests a reference' do
      reference = create(:reference, :cancelled)
      described_class.new(reference, audit_comment: 'somezendesk ticket').call

      expect(reference.reload).to be_feedback_requested
      expect(reference.cancelled_at).to be_nil
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array(reference.email_address)
    end
  end
end
