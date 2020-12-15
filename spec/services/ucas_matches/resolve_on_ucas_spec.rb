require 'rails_helper'

RSpec.describe UCASMatches::ResolveOnUCAS do
  let(:ucas_match) { create(:ucas_match) }
  let(:send_resolved_on_ucas_emails) { instance_double(UCASMatches::SendResolvedOnUCASEmails, call: true) }

  context 'when the application has a ucas_match' do
    before do
      allow(UCASMatches::SendResolvedOnUCASEmails).to receive(:new).with(ucas_match)
                                                                   .and_return(send_resolved_on_ucas_emails)
      described_class.new(ucas_match).call
    end

    it 'sets the application as resolved on UCAS and sends the relevant emails' do
      expect(ucas_match.action_taken).to eq('resolved_on_ucas')

      expect(UCASMatches::SendResolvedOnUCASEmails).to have_received(:new).with(ucas_match)
    end
  end
end
