require 'rails_helper'

RSpec.describe SupportInterface::ApplicationStateMatrixComponent do
  describe '.headers' do
    it 'returns the headers for the matrix table' do
      expect(described_class.new.headers).to contain_exactly(
        'States',
        'Active previous',
        'Carry over',
        'In progress',
        'Interviewable',
        'Offer accepted',
        'Offered',
        'Pending provider decision',
        'Post offered',
        'Reapply',
        'Successful',
        'Terminal',
        'Unsuccessful',
        'Visible to provider',
      )
    end
  end

  describe '.scopes' do
    it 'returns the sorted attributes of an ApplicationStateChange::ApplicationState, except :id' do
      expect(described_class.new.scopes).to eq(%i[
        active_previous
        carry_over
        in_progress
        interviewable
        offer_accepted
        offered
        pending_provider_decision
        post_offered
        reapply
        successful
        terminal
        unsuccessful
        visible_to_provider
      ])
    end
  end
end
