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
    let(:flash) { { success: 'Your application has been updated' } }

    it 'the component is rendered with the correct content' do
      expect(component.css('.govuk-notification-banner__heading').text).to include('Your application has been updated')
    end
  end

  context 'when an info flash key is provided' do
    let(:flash) { { info: 'This service will be unavailable tomorrow' } }

    it 'the component is rendered with a region role' do
      expect(component.css('.govuk-notification-banner').attribute('role').value).to eq('region')
    end
  end

  context 'when a success flash key is provided' do
    let(:flash) { { success: 'Your application has been updated' } }

    it 'the component is rendered with an alert role' do
      expect(component.css('.govuk-notification-banner').attribute('role').value).to eq('alert')
    end
  end

  context 'when a warning flash key is provided' do
    let(:flash) { { warning: 'There is a problem' } }

    it 'the component is rendered with an alert role' do
      expect(component.css('.govuk-notification-banner').attribute('role').value).to eq('alert')
    end
  end

  context 'when a secondary message is provided' do
    let(:flash) { { info: ['Message', 'Some more details...'] } }

    it 'the component is rendered with the correct content' do
      expect(component.text).to include('Message')
      expect(component.text).to include('Some more details...')
    end
  end
end
