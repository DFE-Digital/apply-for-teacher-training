require 'rails_helper'

RSpec.describe UCASMatches::ResolveOnUCAS do
  let(:ucas_match) { create(:ucas_match) }
  let(:send_resolved_on_ucas_emails) { instance_double(UCASMatches::SendResolvedOnUCASEmails, call: true) }

  context 'when the application has a ucas_match' do
    before do
      allow(ucas_match).to receive(:update!).with(hash_including(action_taken: 'resolved_on_ucas'))
      allow(UCASMatches::SendResolvedOnUCASEmails).to receive(:new).with(ucas_match)
                                                                   .and_return(send_resolved_on_ucas_emails)
      described_class.new(ucas_match).call
    end

    it 'sets the application as resolved on UCAS and sends the relevant emails' do
      expect(ucas_match).to have_received(:update!).with(hash_including(action_taken: 'resolved_on_ucas'))

      expect(UCASMatches::SendResolvedOnUCASEmails).to have_received(:new).with(ucas_match)
    end
  end
end
