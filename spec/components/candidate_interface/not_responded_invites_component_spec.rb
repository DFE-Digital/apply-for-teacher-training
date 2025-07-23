require 'rails_helper'

RSpec.describe CandidateInterface::NotRespondedInvitesComponent do
  describe '#hint_text' do
    it 'returns no invites message when no invites' do
      component = described_class.new(invites: [])
      render_inline(component)

      expect(component.hint_text).to eq('You have no invitations that you need to respond to at the moment.')
    end

    it 'returns invites message when there are invites' do
      component = described_class.new(invites: [create(:pool_invite)])
      render_inline(component)

      expect(component.hint_text).to eq('You should respond to each invitation to apply that you receive.')
    end
  end
end
