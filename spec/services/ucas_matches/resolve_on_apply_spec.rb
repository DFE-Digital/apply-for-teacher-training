require 'rails_helper'

RSpec.describe UCASMatches::ResolveOnApply do
  let(:ucas_match) { create(:ucas_match) }
  let(:send_resolved_on_ucas_emails) { instance_double(UCASMatches::SendResolvedOnApplyEmails, call: true) }

  context 'when the application has a ucas_match' do
    before do
      allow(UCASMatches::SendResolvedOnApplyEmails).to receive(:new).with(ucas_match).and_return(send_resolved_on_ucas_emails)

      described_class.new(ucas_match).call
    end

    it 'sets the application as resolved on Apply and sends the relevant emails' do
      expect(ucas_match.action_taken).to eq('resolved_on_apply')

      expect(UCASMatches::SendResolvedOnApplyEmails).to have_received(:new).with(ucas_match)
    end
  end
end
