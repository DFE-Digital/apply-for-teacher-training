require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchActionComponent do
  context 'when there is no dual application or dual acceptance' do
    it 'renders `No action required`' do
      ucas_match_without_dual_applications = create(:ucas_match, matching_state: 'new_match', scheme: 'U', ucas_status: :rejected)
      allow(ucas_match_without_dual_applications).to receive(:dual_application_or_dual_acceptance?).and_return(false)

      result = render_inline(described_class.new(ucas_match_without_dual_applications))
      expect(result.text).to include('No action required')
    end
  end

  context 'when there is a dual application or dual acceptance' do
    it 'renders correct information for a new match' do
      ucas_match = create(:ucas_match, matching_state: 'new_match', scheme: 'U', candidate_last_contacted_at: nil)
      allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

      result = render_inline(described_class.new(ucas_match))

      expect(result.text).to include('Action needed Send initial emails')
      expect(result.css('input').attr('value').value).to include('Confirm initial emails were sent')
      expect(result.css('form').attr('action').value).to include('/record-initial-emails-sent')
      expect(result.text).to include('We need to contact the candidate and the provider.')
    end

    it 'renders correct information after sending the initial emails' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'new_match',
                            scheme: 'U',
                            action_taken: 'initial_emails_sent',
                            candidate_last_contacted_at: Time.zone.now - 1.day)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('No action required')
        expect(result.text).to include('We sent the initial emails on the 18 October 2020')
      end
    end
  end
end
