require 'rails_helper'

RSpec.describe EndOfCycleEmailsComponent do
  context 'when preview email is enabled' do
    it 'renders preview email links' do
      result = render_inline(described_class.new)

      expect(result.css('.govuk-table__body a').map(&:text)).to eq([
        'Apply deadline first reminder',
        'Apply deadline second reminder',
        'Find has opened',
        'Apply has opened',
        'Find is now open (providers)',
      ])
    end
  end

  context 'when preview is disabled' do
    it 'renders texts without preview links' do
      allow(Rails.application.config.action_mailer).to receive(:show_previews).and_return(false)
      result = render_inline(described_class.new)

      expect(result.css('.govuk-table__body a').map(&:text)).to eq([])
      expect(result.css('.govuk-table__body th').map(&:text)).to eq([
        'Apply deadline first reminder',
        'Apply deadline second reminder',
        'Find has opened',
        'Apply has opened',
        'Find is now open (providers)',
      ])
    end
  end
end
