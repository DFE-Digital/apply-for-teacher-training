require 'rails_helper'

RSpec.describe FlashMessageComponent do
  let(:component) { render_inline(described_class.new(flash: flash)) }
  let(:flash) { {} }

  it 'does not render any content when flash is not set' do
    expect(component.text).to be_empty
  end

  context 'when an invalid flash key is provided' do
    let(:flash) { { alert: 'Message' } }

    it 'fails when an invalid key is provided' do
      expect(component.text).to be_empty
    end
  end

  context 'when a valid flash key is provided' do
    let(:flash) { { info: 'Your application has been updated' } }

    it 'the component is rendered with the correct content' do
      expect(component.css('.govuk-notification-banner__heading').text).to include('Your application has been updated')
    end
  end
end
