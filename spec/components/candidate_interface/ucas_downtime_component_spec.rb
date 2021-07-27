require 'rails_helper'

RSpec.describe CandidateInterface::UCASDowntimeComponent do
  context 'when the banner for UCAS downtime feature flag is on' do
    it 'renders the banner' do
      FeatureFlag.activate('banner_for_ucas_downtime')

      result = render_inline(described_class.new)

      expect(result.text).to include('UCAS services will not be available from 6pm on Friday 24 April until Sunday 26 April.')
    end
  end

  context 'when the banner for UCAS downtime feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('banner_for_ucas_downtime')

      result = render_inline(described_class.new)

      expect(result.text).to eq('')
    end
  end
end
